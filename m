Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50058 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbaEGTZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 15:25:34 -0400
Date: Wed, 7 May 2014 15:25:34 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 29/70] NFSd: Add a struct nfs4_file field to struct
 nfs4_stid
Message-ID: <20140507192534.GD8324@fieldses.org>
References: <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're adding a put without adding a corresponding get, so was there a
leak before this patch?

--b.

On Fri, Apr 18, 2014 at 02:44:23PM -0400, Trond Myklebust wrote:
> All stateids are associated with a nfs4_file. Let's consolidate...
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 2 ++
>  fs/nfsd/state.h     | 1 +
>  2 files changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 32ab3f1c83f8..5bbef4720e7c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -474,6 +474,8 @@ static void remove_stid(struct nfs4_stid *s)
>  
>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
>  {
> +	if (s->sc_file)
> +		put_nfs4_file(s->sc_file);
>  	kmem_cache_free(slab, s);
>  }
>  
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 9d0088c244a8..c6deef936693 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -85,6 +85,7 @@ struct nfs4_stid {
>  	unsigned char sc_type;
>  	stateid_t sc_stateid;
>  	struct nfs4_client *sc_client;
> +	struct nfs4_file *sc_file;
>  };
>  
>  struct nfs4_delegation {
> -- 
> 1.9.0
> 
