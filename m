Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756598Ab3KHNWG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 08:22:06 -0500
Date: Fri, 8 Nov 2013 08:22:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108082202.4032f1a2@tlielax.poochiereds.net>
In-Reply-To: <527CDBFC.3070903@RedHat.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
	<A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
	<527C07B4.800@RedHat.com>
	<44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
	<527CDBFC.3070903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Nov 2013 07:41:32 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 07/11/13 18:05, Chuck Lever wrote:
> > 
> > On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >> Hey mrchuck... 
> >>
> >> On 07/11/13 14:25, Chuck Lever wrote:
> >>> Hi Steve-
> >>>
> >>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
> >>>
> >>>> This new module parameter makes the v4 client
> >>>> use the minimal authentication flavor (AUTH_UNIX)
> >>>> when establishing NFSV4 state and doing the
> >>>> pseudoroot lookup
> >>>
> >>> The patch description doesn't say, but is this change to work 
> >>> around the 15 second GSSD upcall timeout? 
> >> Yes. A 15 second delay on every mount due to security that
> >> nobody is requesting is just not good.. IMHO..
> > 
> > One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
> > as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
> > you expect the mount to work (ie why would it be good for any properly configured 
> > environment to take 15 seconds to establish a GSS context?).
> > 
> > In other words, there are still cases where users wait 15 seconds unnecessarily, 
> > and not because of the use of krb5i for lease management.  Aren't those of concern?
> No. I think the concern here, at least my concern, is the lack of management.
> We are forcing admins to use krb5i in lease management when its not necessary
> and there is no way to turn it off.
>   

I don't think that's really the case. The idea was to have the client
attempt to use krb5i if it's available, and then to fall back to
AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
GSSAPI upcall succeeded or failed immediately instead of requiring this
timeout when the daemon isn't running.

> > 
> >> Also running
> >> a security daemon for non-secure mounts just seems wrong to me.
> > 
> > It seems wrong to me to keep auth_rpcgss loaded if no mounts use Kerberos security.  
> > What's the difference between that and running gssd all the time?
> You can say thing about %99 of all the modules load in a Fedora kernel today.
> lsmod | wc -l show there is 107 modules load on a f19 system. Do you think
> all those modules are used? Of course not, but they are not spewing 25
> log messages per mount or sucking up CPU cycles unnecessarily. 
> 

rpc.gssd spends most of its time sleeping, unless there is
nfs mount or "real" gssapi activity. CPU cycles shouldn't be an issue.
The RSS for the process on my 64-bit box is ~2k so I wouldn't even be
concerned about memory usage. For comparison, we don't worry much about
running rpc.statd these days and it's of similar size and duty cycle.

The log messages are another matter. rpc.gssd is just too chatty by
default. That's fixable, but it would mean that we'd need to tell
people to run it in verbose mode when tracking down problems instead of
assuming that all of those messages would go to the logs. That seems
like a reasonable thing to do anyway. Most people don't care about
rpc.gssd log messages once they have kerberized NFS working.


> > 
> > The new SETCLIENTID architecture would be transparent if our security 
> > infrastructure was reliable.  We really need to address the upcall issue.  
> > We've been working around it for a very long time.
> But its not transparent at this point. So we need a way to disable it
> until it comes transparent. That is what this module parameter does.
> 
> > 
> >>
> >>> Have we completely given up on fixing the upcall?
> >> Back when we were looking on to introduce gss-proxy into
> >> the client, it was decided the upcall on the client
> >> was not going to change. I'm just going with that!
> > 
> > I don't remember that discussion.  Or if it occurred, I didn't 
> > realize at the time that it was referring to fixing bugs.  
> > Do you have a link to the thread?
> It was when we were discussing how to use gss-proxy. If I 
> remember correctly it was a verbal discussion... 
> 
> steved.
>  
> > 
> > 
> >> steved.
> >>
> >>
> >>>
> >>>
> >>>> Signed-off-by: Steve Dickson <steved@redhat.com>
> >>>> ---
> >>>> fs/nfs/nfs4_fs.h    |    1 +
> >>>> fs/nfs/nfs4client.c |    8 ++++++--
> >>>> fs/nfs/nfs4proc.c   |    4 +++-
> >>>> fs/nfs/super.c      |    6 +++++-
> >>>> 4 files changed, 15 insertions(+), 4 deletions(-)
> >>>>
> >>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> >>>> index 28842ab..20bf925 100644
> >>>> --- a/fs/nfs/nfs4_fs.h
> >>>> +++ b/fs/nfs/nfs4_fs.h
> >>>> @@ -438,6 +438,7 @@ extern bool nfs4_disable_idmapping;
> >>>> extern unsigned short max_session_slots;
> >>>> extern unsigned short send_implementation_id;
> >>>> extern bool recover_lost_locks;
> >>>> +extern bool nfs4_use_min_auth;
> >>>>
> >>>> #define NFS4_CLIENT_ID_UNIQ_LEN		(64)
> >>>> extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
> >>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> >>>> index a860ab5..ff85991 100644
> >>>> --- a/fs/nfs/nfs4client.c
> >>>> +++ b/fs/nfs/nfs4client.c
> >>>> @@ -355,6 +355,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>>> 	char buf[INET6_ADDRSTRLEN + 1];
> >>>> 	struct nfs_client *old;
> >>>> 	int error;
> >>>> +	rpc_authflavor_t flavor = RPC_AUTH_GSS_KRB5I;
> >>>>
> >>>> 	if (clp->cl_cons_state == NFS_CS_READY) {
> >>>> 		/* the client is initialised already */
> >>>> @@ -368,8 +369,11 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>>> 	if (clp->cl_minorversion != 0)
> >>>> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
> >>>> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
> >>>> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
> >>>> -	if (error == -EINVAL)
> >>>> +
> >>>> +	if (nfs4_use_min_auth)
> >>>> +		flavor = RPC_AUTH_UNIX;
> >>>> +	error = nfs_create_rpc_client(clp, timeparms, flavor);
> >>>> +	if (error == -EINVAL && flavor != RPC_AUTH_UNIX)
> >>>> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
> >>>> 	if (error < 0)
> >>>> 		goto error;
> >>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >>>> index d53d678..00162cb 100644
> >>>> --- a/fs/nfs/nfs4proc.c
> >>>> +++ b/fs/nfs/nfs4proc.c
> >>>> @@ -2864,7 +2864,9 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> >>>> 	int status = -EPERM;
> >>>> 	size_t i;
> >>>>
> >>>> -	for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> >>>> +	if (nfs4_use_min_auth)
> >>>> +		status = nfs4_lookup_root_sec(server, fhandle, info, RPC_AUTH_UNIX);
> >>>> +	else for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> >>>> 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
> >>>> 		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
> >>>> 			continue;
> >>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> >>>> index a03b9c6..42b4f9b 100644
> >>>> --- a/fs/nfs/super.c
> >>>> +++ b/fs/nfs/super.c
> >>>> @@ -2791,6 +2791,7 @@ unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
> >>>> unsigned short send_implementation_id = 1;
> >>>> char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN] = "";
> >>>> bool recover_lost_locks = false;
> >>>> +bool nfs4_use_min_auth = false;
> >>>>
> >>>> EXPORT_SYMBOL_GPL(nfs_callback_set_tcpport);
> >>>> EXPORT_SYMBOL_GPL(nfs_callback_tcpport);
> >>>> @@ -2800,6 +2801,7 @@ EXPORT_SYMBOL_GPL(max_session_slots);
> >>>> EXPORT_SYMBOL_GPL(send_implementation_id);
> >>>> EXPORT_SYMBOL_GPL(nfs4_client_id_uniquifier);
> >>>> EXPORT_SYMBOL_GPL(recover_lost_locks);
> >>>> +EXPORT_SYMBOL_GPL(nfs4_use_min_auth);
> >>>>
> >>>> #define NFS_CALLBACK_MAXPORTNR (65535U)
> >>>>
> >>>> @@ -2842,5 +2844,7 @@ MODULE_PARM_DESC(recover_lost_locks,
> >>>> 		 "If the server reports that a lock might be lost, "
> >>>> 		 "try to recover it risking data corruption.");
> >>>>
> >>>> -
> >>>> +module_param(nfs4_use_min_auth, bool, 0644);
> >>>> +MODULE_PARM_DESC(nfs4_use_min_auth,
> >>>> +		"Use mimnal auth in SETCLIENTID operation");
> >>>> #endif /* CONFIG_NFS_V4 */
> >>>> -- 
> >>>> 1.7.1
> >>>>
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >>> --
> >>> Chuck Lever
> >>> chuck[dot]lever[at]oracle[dot]com
> >>>
> >>>
> >>>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > --
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> > 
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>
