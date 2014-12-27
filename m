Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:46907 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbaL0QUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Dec 2014 11:20:00 -0500
Date: Sat, 27 Dec 2014 21:49:28 +0530
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Koshy George <koshygp@gmail.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: nfs4_fs.h: Fix for checkpatch warnings
Message-ID: <20141227161928.GA2075@fool>
References: <1419679857-16626-1-git-send-email-koshygp@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1419679857-16626-1-git-send-email-koshygp@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 27, 2014 at 04:30:57AM -0700, Koshy George wrote:
> This patch fix checkpatch warning for nfs4_fs.h
> 
> fs/nfs/nfs4_fs.h:134: ERROR: "foo *	bar" should be "foo *bar"
> fs/nfs/nfs4_fs.h:416: ERROR: "foo * bar" should be "foo *bar"
> 
> Signed-off-by: Koshy George <koshygp@gmail.com>
> [Being first patch, need some assistance]

this should not come here. any comment like this you can place below the ---
And actually its better to try generate your first patch on staging. There are lots of things to fix there.

thanks
sudip
> ---
>  fs/nfs/nfs4_fs.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index a081787..ae336c7 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -131,7 +131,7 @@ enum {
>  
>  struct nfs4_lock_state {
>  	struct list_head	ls_locks;	/* Other lock stateids */
> -	struct nfs4_state *	ls_state;	/* Pointer to open state */
> +	struct nfs4_state	*ls_state;	/* Pointer to open state */
>  #define NFS_LOCK_INITIALIZED 0
>  #define NFS_LOCK_LOST        1
>  	unsigned long		ls_flags;
> @@ -413,7 +413,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session,
>  extern struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *, gfp_t);
>  extern void nfs4_put_state_owner(struct nfs4_state_owner *);
>  extern void nfs4_purge_state_owners(struct nfs_server *);
> -extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
> +extern struct nfs4_state *nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
>  extern void nfs4_put_open_state(struct nfs4_state *);
>  extern void nfs4_close_state(struct nfs4_state *, fmode_t);
>  extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
