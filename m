Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:64686 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbaHALU1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2014 07:20:27 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so5524176qgd.23
        for <linux-nfs@vger.kernel.org>; Fri, 01 Aug 2014 04:20:26 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 1 Aug 2014 07:20:25 -0400
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 36/37] nfsd: remove the client_mutex and the
 nfs4_lock/unlock_state wrappers
Message-ID: <20140801072025.63f145b6@tlielax.poochiereds.net>
In-Reply-To: <1406723258-8512-37-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
	<1406723258-8512-37-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Jul 2014 08:27:37 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a33ce55925fb..de811dc39061 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -75,9 +75,6 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid);
>  
>  /* Locking: */
>  
> -/* Currently used for almost all code touching nfsv4 state: */
> -static DEFINE_MUTEX(client_mutex);
> -
>  /*
>   * Currently used for the del_recall_lru and file hash table.  In an
>   * effort to decrease the scope of the client_mutex, this spinlock may
> @@ -97,12 +94,6 @@ static struct kmem_cache *file_slab;
>  static struct kmem_cache *stateid_slab;
>  static struct kmem_cache *deleg_slab;
>  
> -void
> -nfs4_lock_state(void)
> -{
> -	mutex_lock(&client_mutex);
> -}
> -
>  static void free_session(struct nfsd4_session *);
>  
>  static bool is_session_dead(struct nfsd4_session *ses)
> @@ -118,12 +109,6 @@ static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_b
>  	return nfs_ok;
>  }
>  
> -void
> -nfs4_unlock_state(void)
> -{
> -	mutex_unlock(&client_mutex);
> -}
> -
>  static bool is_client_expired(struct nfs4_client *clp)
>  {
>  	return clp->cl_time == 0;

I just noticed that the above patch neglects to remove the declarations
of nfs4_lock/unlock_state from state.h. Bruce, let me know if you want me
to resend. Otherwise, I'll assume that you can fix that up.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
