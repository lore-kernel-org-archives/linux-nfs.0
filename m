Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:45839 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751894AbeCWKzf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2018 06:55:35 -0400
Received: by mail-qt0-f196.google.com with SMTP id f8so12026620qtg.12
        for <linux-nfs@vger.kernel.org>; Fri, 23 Mar 2018 03:55:35 -0700 (PDT)
Message-ID: <1521802532.4757.0.camel@redhat.com>
Subject: Re: [PATCH] nfs: Use ida_simple API
From: Jeff Layton <jlayton@redhat.com>
To: Matthew Wilcox <willy@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 23 Mar 2018 06:55:32 -0400
In-Reply-To: <20180315024827.GA9973@bombadil.infradead.org>
References: <20180315024827.GA9973@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-03-14 at 19:48 -0700, Matthew Wilcox wrote:
> Allocate the owner_id when we allocate the state and free it when we free
> the state.  That lets us get rid of a gnarly ida_pre_get() / ida_get_new()
> loop.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 91a4d4eeb235..c10a422efe6f 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -428,7 +428,6 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
>  	struct rb_node **p = &server->state_owners.rb_node,
>  		       *parent = NULL;
>  	struct nfs4_state_owner *sp;
> -	int err;
>  
>  	while (*p != NULL) {
>  		parent = *p;
> @@ -445,9 +444,6 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
>  			return sp;
>  		}
>  	}
> -	err = ida_get_new(&server->openowner_id, &new->so_seqid.owner_id);
> -	if (err)
> -		return ERR_PTR(err);
>  	rb_link_node(&new->so_server_node, parent, p);
>  	rb_insert_color(&new->so_server_node, &server->state_owners);
>  	return new;
> @@ -460,7 +456,6 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
>  
>  	if (!RB_EMPTY_NODE(&sp->so_server_node))
>  		rb_erase(&sp->so_server_node, &server->state_owners);
> -	ida_remove(&server->openowner_id, sp->so_seqid.owner_id);
>  }
>  
>  static void
> @@ -495,6 +490,12 @@ nfs4_alloc_state_owner(struct nfs_server *server,
>  	sp = kzalloc(sizeof(*sp), gfp_flags);
>  	if (!sp)
>  		return NULL;
> +	sp->so_seqid.owner_id = ida_simple_get(&server->openowner_id, 0, 0,
> +						gfp_flags);
> +	if (sp->so_seqid.owner_id < 0) {
> +		kfree(sp);
> +		return NULL;
> +	}
>  	sp->so_server = server;
>  	sp->so_cred = get_rpccred(cred);
>  	spin_lock_init(&sp->so_lock);
> @@ -526,6 +527,7 @@ static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
>  {
>  	nfs4_destroy_seqid_counter(&sp->so_seqid);
>  	put_rpccred(sp->so_cred);
> +	ida_simple_remove(&sp->so_server->openowner_id, sp->so_seqid.owner_id);
>  	kfree(sp);
>  }
>  
> @@ -576,13 +578,9 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
>  	new = nfs4_alloc_state_owner(server, cred, gfp_flags);
>  	if (new == NULL)
>  		goto out;
> -	do {
> -		if (ida_pre_get(&server->openowner_id, gfp_flags) == 0)
> -			break;
> -		spin_lock(&clp->cl_lock);
> -		sp = nfs4_insert_state_owner_locked(new);
> -		spin_unlock(&clp->cl_lock);
> -	} while (sp == ERR_PTR(-EAGAIN));
> +	spin_lock(&clp->cl_lock);
> +	sp = nfs4_insert_state_owner_locked(new);
> +	spin_unlock(&clp->cl_lock);
>  	if (sp != new)
>  		nfs4_free_state_owner(new);
>  out:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
