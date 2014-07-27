Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58571 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaG0NfI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:35:08 -0400
Date: Sun, 27 Jul 2014 06:35:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 06/40] nfsd: Cleanup the freeing of stateids
Message-ID: <20140727133507.GH32153@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 11:02:18AM -0400, Jeff Layton wrote:
> Add a ->free() callback to the struct nfs4_stid, so that we can
> release a reference to the stid without caring about the contents.

Looks good, but I'd do it much earlier so that the nfs4_put_stid doesn't
have to change around again - IMHO adding the free callback should go
together with introducing the refcounting, as it's kinda required
to do the refcounting sanely.

Also when Trond first posted this I suggested to introduce an ops vector
instead of a free callback as there wil be a lot more things in the
stateid handling that could make use of it.  I'm not going to insist on
the ops vector at this point, but I think it would make things quite
a bit cleaner.


> +static void nfs4_free_generic_stateid(struct nfs4_stid *stid);

s/generic/ol/

Also maybe just move it into the right place instead of the forward
declaration given how trivial it is?

> +static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> +{
> +	if (s->sc_file)
> +		put_nfs4_file(s->sc_file);
> +	kmem_cache_free(slab, s);
> +}

I think the layering here is wrong - the generic code should put the
file before calling into the ->free method as the file is in the
generic code.  Then the free callback can simply opencode the
kmem_cache_free instead of adding this helper.

> +static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
> +					 struct kmem_cache *slab)
>  {
>  	struct nfs4_stid *stid;
>  	int new_id;
> @@ -492,7 +500,22 @@ out_free:
>  
>  static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
>  {

Having and nfs4_alloc_stid and an nfs4_alloc_stateid is a very confusing
nameing scheme.  I think nfs4_alloc_stateid should be rename to
nfs4_alloc_ol_stateid.  And nfs4_alloc_stid might actually just be
redone to nfs4_init_stid, leaving the allocation to the caller similar
how the specific type handles the free in the ->free callback.

>  void
>  nfs4_put_delegation(struct nfs4_delegation *dp)
>  {
> -	if (nfs4_put_stid(deleg_slab, &dp->dl_stid))
> -		atomic_long_dec(&num_delegations);
> +	nfs4_put_stid(&dp->dl_stid);
>  }

And reason to keep nfs4_put_delegation around?

>  static void put_generic_stateid(struct nfs4_ol_stateid *stp)
>  {
> -	nfs4_put_stid(stateid_slab, &stp->st_stid);
> +	nfs4_put_stid(&stp->st_stid);
>  }

Ditto for put_generic_stateid.

