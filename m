Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60541 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753977Ab3IEPbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 11:31:25 -0400
Date: Thu, 5 Sep 2013 11:31:21 -0400
From: Dr James Bruce Fields <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: use mach cred for SECINFO_NO_NAME w/ integrity
Message-ID: <20130905153121.GJ10232@fieldses.org>
References: <1378311199-1695-1-git-send-email-dros@netapp.com>
 <1378311850.3527.16.camel@leira.trondhjem.org>
 <F4CF12A0-4D67-4C6B-8413-CC2E895E1B9F@netapp.com>
 <1378341909.6143.1.camel@leira.trondhjem.org>
 <20130905140718.GI10232@fieldses.org>
 <ECF01CCB-9391-46C9-8542-8F9163D58E8A@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <ECF01CCB-9391-46C9-8542-8F9163D58E8A@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 03:17:37PM +0000, Adamson, Dros wrote:
> 
> On Sep 5, 2013, at 10:07 AM, Dr James Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Sep 05, 2013 at 12:45:09AM +0000, Myklebust, Trond wrote:
> >> On Wed, 2013-09-04 at 16:48 +0000, Adamson, Dros wrote:
> >>> On Sep 4, 2013, at 12:24 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> >>> 
> >>>> On Wed, 2013-09-04 at 12:13 -0400, Weston Andros Adamson wrote:
> >>>>> Commit 97431204ea005ec8070ac94bc3251e836daa7ca7 introduced a regression
> >>>>> that causes SECINFO_NO_NAME to fail without sending an RPC if:
> >>>>> 
> >>>>> 1) the nfs_client's rpc_client is using krb5i/p (now tried by default)
> >>>>> 2) the current user doesn't have valid kerberos credentials
> >>>>> 
> >>>>> This situation is quite common - as of now a sec=sys mount would use
> >>>>> krb5i for the nfs_client's rpc_client and a user would hardly be faulted
> >>>>> for not having run kinit.
> >>>>> 
> >>>>> The solution is to use the machine cred when trying to use an integrity
> >>>>> protected auth flavor for SECINFO_NO_NAME.
> >>>>> 
> >>>>> Older servers may not support using the machine cred or an integrity
> >>>>> protected auth flavor for SECINFO_NO_NAME in every circumstance, so we fall
> >>>>> back to using the user's cred and the filesystem's auth flavor in this case.
> >>>>> 
> >>>>> We run into another problem when running against linux nfs servers -
> >>>>> they return NFS4ERR_WRONGSEC when using integrity auth flavor (unless the
> >>>>> mount is also that flavor) even though that is not a valid error for
> >>>>> SECINFO*.  Even though it's against spec, handle WRONGSEC errors on
> >>>>> SECINFO_NO_NAME by falling back to using the user cred and the
> >>>>> filesystem's auth flavor.
> >>>>> 
> >>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> >>>>> ---
> >>>>> 
> >>>>> This patch goes along with yesterday's SECINFO patch
> >>>>> 
> >>>>> fs/nfs/nfs4proc.c | 41 +++++++++++++++++++++++++++++++++++++----
> >>>>> 1 file changed, 37 insertions(+), 4 deletions(-)
> >>>>> 
> >>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >>>>> index ab1461e..74b37f5 100644
> >>>>> --- a/fs/nfs/nfs4proc.c
> >>>>> +++ b/fs/nfs/nfs4proc.c
> >>>>> @@ -7291,7 +7291,8 @@ out:
> >>>>> */
> >>>>> static int
> >>>>> _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
> >>>>> -		    struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
> >>>>> +		    struct nfs_fsinfo *info,
> >>>>> +		    struct nfs4_secinfo_flavors *flavors, bool use_integrity)
> >>>>> {
> >>>>> 	struct nfs41_secinfo_no_name_args args = {
> >>>>> 		.style = SECINFO_STYLE_CURRENT_FH,
> >>>>> @@ -7304,8 +7305,23 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
> >>>>> 		.rpc_argp = &args,
> >>>>> 		.rpc_resp = &res,
> >>>>> 	};
> >>>>> -	return nfs4_call_sync(server->nfs_client->cl_rpcclient, server, &msg,
> >>>>> -				&args.seq_args, &res.seq_res, 0);
> >>>>> +	struct rpc_clnt *clnt = server->client;
> >>>>> +	int status;
> >>>>> +
> >>>>> +	if (use_integrity) {
> >>>>> +		clnt = server->nfs_client->cl_rpcclient;
> >>>>> +		msg.rpc_cred = nfs4_get_clid_cred(server->nfs_client);
> >>>>> +	}
> >>>>> +
> >>>>> +	dprintk("--> %s\n", __func__);
> >>>>> +	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
> >>>>> +				&res.seq_res, 0);
> >>>>> +	dprintk("<-- %s status=%d\n", __func__, status);
> >>>>> +
> >>>>> +	if (msg.rpc_cred)
> >>>>> +		put_rpccred(msg.rpc_cred);
> >>>>> +
> >>>>> +	return status;
> >>>>> }
> >>>>> 
> >>>>> static int
> >>>>> @@ -7315,7 +7331,24 @@ nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
> >>>>> 	struct nfs4_exception exception = { };
> >>>>> 	int err;
> >>>>> 	do {
> >>>>> -		err = _nfs41_proc_secinfo_no_name(server, fhandle, info, flavors);
> >>>>> +		/* first try using integrity protection */
> >>>>> +		err = -NFS4ERR_WRONGSEC;
> >>>>> +
> >>>>> +		/* try to use integrity protection with machine cred */
> >>>>> +		if (_nfs4_is_integrity_protected(server->nfs_client))
> >>>>> +			err = _nfs41_proc_secinfo_no_name(server, fhandle, info,
> >>>>> +							  flavors, true);
> >>>>> +
> >>>>> +		/*
> >>>>> +		 * if unable to use integrity protection, or SECINFO with
> >>>>> +		 * integrity protection returns NFS4ERR_WRONGSEC (which is
> >>>>> +		 * disallowed by spec, but exists in deployed servers) use
> >>>>> +		 * the current filesystem's rpc_client and the user cred.
> >>>>> +		 */
> >>>>> +		if (err == -NFS4ERR_WRONGSEC)
> >>>>> +			err = _nfs41_proc_secinfo_no_name(server, fhandle, info,
> >>>>> +							  flavors, false);
> >>>> 
> >>>> As I said yesterday, RFC5661 forbids SECINFO_NO_NAME from returning
> >>>> NFS4ERR_WRONGSEC, so this is 100% equivalent to
> >>>> 
> >>>> 	if (!_nfs4_is_integrity_protected())
> >>>> 		err = ….
> >>> 
> >>> Right, but I thought we were doing this to support server implementations like linux that *do* return NFS4ERR_WRONGSEC on SECINFO_NO_NAME even though it's forbidden.  I know we normally don't work around server bugs, but this seems pretty simple.
> >>> 
> >>> If we don't do this, then SECINFO_NO_NAME will always fail against current linux severs no matter what the mount options - unless krb5i/p is unusable (not configured, time skew, no machine cred, etc).
> >> 
> >> Bruce, you're it: what's the deal here?
> > 
> > Dros, in what cases exactly do you see SECINFO_NO_NAME returning
> > WRONGSEC?
> > 
> > From a quick skim of the code it looks like it shouldn't happen in the
> > CURRENT_FH case, which is the one the client uses.  But I probably
> > overlooked something....
> > 
> > --b.
> 
> SECINFO_NO_NAME will fail with NFS4ERR_WRONGSEC in check_nfsd_access when the rpc auth flavor is different from the export's auth flavor - in the same way as SECINFO.

Huh.  There's no check_nfsd_access call in secinfo_no_name in the
CURRENT_FH case.  And any checks on the putfh op should be turned off by
the OP_HANDLES_WRONGSEC flag on secinfo_no_name.

But I haven't actually tried it, and presumably you have (any hints on
reproducing?), so I'll take a look....

--b.
