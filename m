Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55891 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758024Ab3IEUko (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 16:40:44 -0400
Date: Thu, 5 Sep 2013 16:40:41 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: use mach cred for SECINFO_NO_NAME w/ integrity
Message-ID: <20130905204041.GA24805@fieldses.org>
References: <1378311199-1695-1-git-send-email-dros@netapp.com>
 <1378401946.5450.13.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378401946.5450.13.camel@leira.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 05:25:48PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-09-04 at 12:13 -0400, Weston Andros Adamson wrote:
> > Commit 97431204ea005ec8070ac94bc3251e836daa7ca7 introduced a regression
> > that causes SECINFO_NO_NAME to fail without sending an RPC if:
> > 
> >  1) the nfs_client's rpc_client is using krb5i/p (now tried by default)
> >  2) the current user doesn't have valid kerberos credentials
> > 
> > This situation is quite common - as of now a sec=sys mount would use
> > krb5i for the nfs_client's rpc_client and a user would hardly be faulted
> > for not having run kinit.
> > 
> > The solution is to use the machine cred when trying to use an integrity
> > protected auth flavor for SECINFO_NO_NAME.
> > 
> > Older servers may not support using the machine cred or an integrity
> > protected auth flavor for SECINFO_NO_NAME in every circumstance, so we fall
> > back to using the user's cred and the filesystem's auth flavor in this case.
> > 
> > We run into another problem when running against linux nfs servers -
> > they return NFS4ERR_WRONGSEC when using integrity auth flavor (unless the
> > mount is also that flavor) even though that is not a valid error for
> > SECINFO*.  Even though it's against spec, handle WRONGSEC errors on
> > SECINFO_NO_NAME by falling back to using the user cred and the
> > filesystem's auth flavor.
> > 
> > Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> > ---
> > 
> > This patch goes along with yesterday's SECINFO patch
> > 
> >  fs/nfs/nfs4proc.c | 41 +++++++++++++++++++++++++++++++++++++----
> >  1 file changed, 37 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index ab1461e..74b37f5 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -7291,7 +7291,8 @@ out:
> >   */
> >  static int
> >  _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
> > -		    struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
> > +		    struct nfs_fsinfo *info,
> > +		    struct nfs4_secinfo_flavors *flavors, bool use_integrity)
> >  {
> >  	struct nfs41_secinfo_no_name_args args = {
> >  		.style = SECINFO_STYLE_CURRENT_FH,
> > @@ -7304,8 +7305,23 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
> >  		.rpc_argp = &args,
> >  		.rpc_resp = &res,
> >  	};
> > -	return nfs4_call_sync(server->nfs_client->cl_rpcclient, server, &msg,
> > -				&args.seq_args, &res.seq_res, 0);
> > +	struct rpc_clnt *clnt = server->client;
> > +	int status;
> > +
> > +	if (use_integrity) {
> > +		clnt = server->nfs_client->cl_rpcclient;
> > +		msg.rpc_cred = nfs4_get_clid_cred(server->nfs_client);
> > +	}
> > +
> > +	dprintk("--> %s\n", __func__);
> > +	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
> > +				&res.seq_res, 0);
> > +	dprintk("<-- %s status=%d\n", __func__, status);
> > +
> > +	if (msg.rpc_cred)
> > +		put_rpccred(msg.rpc_cred);
> > +
> > +	return status;
> >  }
> 
> I have a question: if we use the machine credential, don't we risk a
> NFS4ERR_ACCESS due to the directory permission settings?
> 
> I don't see anything in the spec about what permissions you do need for
> a SECINFO_NO_NAME, but since NFS4ERR_ACCESS is listed as a valid return
> code, I'm assuming that the server may enforce lookup permissions...

It needs to in the STYLE4_PARENT case, but it would seem very strange in
the CURRENT_FH case where there's no real "lookup".


(If anyone's allowed SECINFO_NO_NAME with CURRENT_FH, would that give
away too much information?  I'm not sure.  I don't think many
administrators would be surprised by the fact that anyone could discover
the set of exported filesystems and their security flavors.  People are
used to that being visible through showmount, for example.

Maybe there's some scenario where somebody would care just about the
ability to probe whether a given filehandle is valid or not, e.g.  to
see whether a given file had been deleted or not.  But you can already
get that information by sending a bare PUTFH and checking the error.

We could close that minor information leak by checking the export flavor
as soon as we've parsed enough of the filehandle to identify the export,
before trying to find the actual file.  And SECINFO_NO_NAME with
CURRENT_FH could similarly be allowed to succeed as soon as we've
identified the export (we don't need any more as long as security
flavors are set only per-export).  I'm not sure anyone cares.)

--b.
