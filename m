Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36727 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933326AbbJANHd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Oct 2015 09:07:33 -0400
Received: by qgx61 with SMTP id 61so64257422qgx.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2015 06:07:33 -0700 (PDT)
Date: Thu, 1 Oct 2015 09:07:30 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add a spinlock to nfs4_stid
Message-ID: <20151001090730.15c7dd92@tlielax.poochiereds.net>
In-Reply-To: <1443704750-7277-1-git-send-email-jeff.layton@primarydata.com>
References: <1443704750-7277-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  1 Oct 2015 09:05:50 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> ...to allow seqid morphing to be serialized wrt to its copying.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c |  1 +
>  fs/nfsd/state.h     | 13 +++++++------
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bec2cc7eac78..156fc9183728 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -577,6 +577,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
>  	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
>  	/* Will be incremented before return to client: */
>  	atomic_set(&stid->sc_count, 1);
> +	spin_lock_init(&stid->sc_lock);
>  
>  	/*
>  	 * It shouldn't be a problem to reuse an opaque stateid value.
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 6f35fec88517..e3a191ea771c 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -84,7 +84,7 @@ struct nfsd4_callback_ops {
>   * fields that are of general use to any stateid.
>   */
>  struct nfs4_stid {
> -	atomic_t sc_count;
> +	atomic_t		sc_count;
>  #define NFS4_OPEN_STID 1
>  #define NFS4_LOCK_STID 2
>  #define NFS4_DELEG_STID 4
> @@ -94,11 +94,12 @@ struct nfs4_stid {
>  #define NFS4_REVOKED_DELEG_STID 16
>  #define NFS4_CLOSED_DELEG_STID 32
>  #define NFS4_LAYOUT_STID 64
> -	unsigned char sc_type;
> -	stateid_t sc_stateid;
> -	struct nfs4_client *sc_client;
> -	struct nfs4_file *sc_file;
> -	void (*sc_free)(struct nfs4_stid *);
> +	unsigned char		sc_type;
> +	stateid_t		sc_stateid;
> +	spinlock_t		sc_lock;
> +	struct nfs4_client	*sc_client;
> +	struct nfs4_file	*sc_file;
> +	void			(*sc_free)(struct nfs4_stid *);
>  };
>  
>  /*

Obviously the previously sent patch should be squashed in with this
one. I meant to squash them before sending, but forgot. I'll do that if
I need to respin though.

-- 
Jeff Layton <jlayton@poochiereds.net>
