Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab3HERhu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Aug 2013 13:37:50 -0400
Date: Mon, 5 Aug 2013 13:37:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Nix <nix@esperi.org.uk>,
        Toralf =?ISO-8859-1?B?RvZyc3Rlcg==?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic
 from 3.9.*
Message-ID: <20130805133739.21654ecb@tlielax.poochiereds.net>
In-Reply-To: <1375719301.7337.14.camel@leira.trondhjem.org>
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	<20130805084436.69ee4415@corrin.poochiereds.net>
	<87siyotcri.fsf@spindle.srvr.nix>
	<20130805110427.509db424@tlielax.poochiereds.net>
	<20130805111106.73d6ab90@tlielax.poochiereds.net>
	<87zjswrvaq.fsf@spindle.srvr.nix>
	<1375719301.7337.14.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 5 Aug 2013 16:15:01 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> From 3c50ba80105464a28d456d9a1e0f1d81d4af92a8 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Mon, 5 Aug 2013 12:06:12 -0400
> Subject: [PATCH] LOCKD: Don't call utsname()->nodename from
>  nlmclnt_setlockargs
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> Firstly, nlmclnt_setlockargs can be called from a reclaimer thread, in
> which case we're in entirely the wrong namespace.
> Secondly, commit 8aac62706adaaf0fab02c4327761561c8bda9448 (move
> exit_task_namespaces() outside of exit_notify()) now means that
> exit_task_work() is called after exit_task_namespaces(), which
> triggers an Oops when we're freeing up the locks.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Toralf Förster <toralf.foerster@gmx.de>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Nix <nix@esperi.org.uk>
> Cc: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/clntproc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 9760ecb..acd3947 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -125,14 +125,15 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
>  {
>  	struct nlm_args	*argp = &req->a_args;
>  	struct nlm_lock	*lock = &argp->lock;
> +	char *nodename = req->a_host->h_rpcclnt->cl_nodename;
>  
>  	nlmclnt_next_cookie(&argp->cookie);
>  	memcpy(&lock->fh, NFS_FH(file_inode(fl->fl_file)), sizeof(struct nfs_fh));
> -	lock->caller  = utsname()->nodename;
> +	lock->caller  = nodename;
>  	lock->oh.data = req->a_owner;
>  	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
>  				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
> -				utsname()->nodename);
> +				nodename);
>  	lock->svid = fl->fl_u.nfs_fl.owner->pid;
>  	lock->fl.fl_start = fl->fl_start;
>  	lock->fl.fl_end = fl->fl_end;

Looks good to me...

Reviewed-by: Jeff Layton <jlayton@redhat.com>

Trond, any thoughts on the other oops that Nix posted? The issue there
seems to be that we're trying to do the pathwalk to the rpcbind unix
socket from exit_task_work(), but that's happening after we've already
called exit_fs().

The trivial answer seems to be to simply call exit_task_work() before
exit_fs() there, but it seems like we ought to be doing the upcall to
rpcbind in a mount namespace from which we know we can reach the
socket...
