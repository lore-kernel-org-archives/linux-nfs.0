Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:57268 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaL0SeT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Dec 2014 13:34:19 -0500
Received: by mail-vc0-f179.google.com with SMTP id le20so4265498vcb.24
        for <linux-nfs@vger.kernel.org>; Sat, 27 Dec 2014 10:34:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1419679857-16626-1-git-send-email-koshygp@gmail.com>
References: <1419679857-16626-1-git-send-email-koshygp@gmail.com>
Date: Sat, 27 Dec 2014 13:34:17 -0500
Message-ID: <CAHQdGtS4iq2d-g-EKu9k_-Kv5pwW-rHkUxQFSCCV5iiB=52vug@mail.gmail.com>
Subject: Re: [PATCH] NFS: nfs4_fs.h: Fix for checkpatch warnings
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Koshy George <koshygp@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 27, 2014 at 6:30 AM, Koshy George <koshygp@gmail.com> wrote:
> This patch fix checkpatch warning for nfs4_fs.h
>
> fs/nfs/nfs4_fs.h:134: ERROR: "foo *     bar" should be "foo *bar"
> fs/nfs/nfs4_fs.h:416: ERROR: "foo * bar" should be "foo *bar"
>
> Signed-off-by: Koshy George <koshygp@gmail.com>
> [Being first patch, need some assistance]
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
>         struct list_head        ls_locks;       /* Other lock stateids */
> -       struct nfs4_state *     ls_state;       /* Pointer to open state */
> +       struct nfs4_state       *ls_state;      /* Pointer to open state */
>  #define NFS_LOCK_INITIALIZED 0
>  #define NFS_LOCK_LOST        1
>         unsigned long           ls_flags;
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

Sorry, but I'm not applying this kind of patch.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
