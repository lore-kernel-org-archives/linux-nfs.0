Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474Ab2BHTbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 14:31:00 -0500
Date: Wed, 8 Feb 2012 14:30:51 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key()
 fails
Message-ID: <20120208143051.38831a84@tlielax.poochiereds.net>
In-Reply-To: <1328727361.3234.27.camel@lade.trondhjem.org>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
	<20120207141254.2948e735@tlielax.poochiereds.net>
	<1328642485.4124.40.camel@lade.trondhjem.org>
	<4F317BA1.4050102@netapp.com>
	<1328643867.4124.42.camel@lade.trondhjem.org>
	<1328645155.4124.44.camel@lade.trondhjem.org>
	<20120208070408.6f77544d@tlielax.poochiereds.net>
	<1328709051.3234.6.camel@lade.trondhjem.org>
	<1328727361.3234.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 8 Feb 2012 18:56:01 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-02-08 at 08:50 -0500, Trond Myklebust wrote:
> > On Wed, 2012-02-08 at 07:04 -0500, Jeff Layton wrote:
> > > On a x86_64 machine:
> > > 
> > > pre-patch:
> > > (gdb) p sizeof(struct idmap)
> > > $1 = 39504
> > > 
> > > post-patch:
> > > (gdb) p sizeof(struct idmap)
> > > $1 = 8784
> > > 
> > > That changes this from an order 4 to an order 2 allocation. Would be
> > > even nicer to get it down to under a page, but this will help
> > > considerably.
> > > 
> > > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > 
> > We could do that by allocating the two idmap_hashent arrays separately.
> > I'll see about that later today.
> 
> Here you go... It now ensures that the arrays don't even get allocated
> at all if you are using the new idmapper...
> 
> 8<------------------------------------------------------------------------
> From 8650c9610f9aeeb536a70feacb488dfb6583090e Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 8 Feb 2012 13:39:15 -0500
> Subject: [PATCH] NFSv4: Further reduce the footprint of the idmapper
> 
> Don't allocate the legacy idmapper tables until we actually need
> them.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/idmap.c |   42 ++++++++++++++++++++++++++++++++++++------
>  1 files changed, 36 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index fff7948..b5c6d8e 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -367,7 +367,7 @@ struct idmap_hashent {
>  
>  struct idmap_hashtable {
>  	__u8			h_type;
> -	struct idmap_hashent	h_entries[IDMAP_HASH_SZ];
> +	struct idmap_hashent	*h_entries;
>  };
>  
>  struct idmap {
> @@ -478,21 +478,40 @@ nfs_idmap_new(struct nfs_client *clp)
>  	return 0;
>  }
>  
> +static void
> +idmap_alloc_hashtable(struct idmap_hashtable *h)
> +{
> +	if (h->h_entries != NULL)
> +		return;
> +	h->h_entries = kcalloc(IDMAP_HASH_SZ,
> +			sizeof(*h->h_entries),
> +			GFP_KERNEL);
> +}
> +
> +static void
> +idmap_free_hashtable(struct idmap_hashtable *h)
> +{
> +	int i;
> +
> +	if (h->h_entries == NULL)
> +		return;
> +	for (i = 0; i < IDMAP_HASH_SZ; i++)
> +		kfree(h->h_entries[i].ih_name);
> +	kfree(h->h_entries);
> +}
> +
>  void
>  nfs_idmap_delete(struct nfs_client *clp)
>  {
>  	struct idmap *idmap = clp->cl_idmap;
> -	int i;
>  
>  	if (!idmap)
>  		return;
>  	nfs_idmap_unregister(clp, idmap->idmap_pipe);
>  	rpc_destroy_pipe_data(idmap->idmap_pipe);
>  	clp->cl_idmap = NULL;
> -	for (i = 0; i < ARRAY_SIZE(idmap->idmap_user_hash.h_entries); i++)
> -		kfree(idmap->idmap_user_hash.h_entries[i].ih_name);
> -	for (i = 0; i < ARRAY_SIZE(idmap->idmap_group_hash.h_entries); i++)
> -		kfree(idmap->idmap_group_hash.h_entries[i].ih_name);
> +	idmap_free_hashtable(&idmap->idmap_user_hash);
> +	idmap_free_hashtable(&idmap->idmap_group_hash);
>  	kfree(idmap);
>  }
>  
> @@ -586,6 +605,8 @@ void nfs_idmap_quit(void)
>  static inline struct idmap_hashent *
>  idmap_name_hash(struct idmap_hashtable* h, const char *name, size_t len)
>  {
> +	if (h->h_entries == NULL)
> +		return NULL;
>  	return &h->h_entries[fnvhash32(name, len) % IDMAP_HASH_SZ];
>  }
>  
> @@ -594,6 +615,8 @@ idmap_lookup_name(struct idmap_hashtable *h, const char *name, size_t len)
>  {
>  	struct idmap_hashent *he = idmap_name_hash(h, name, len);
>  
> +	if (he == NULL)
> +		return NULL;
>  	if (he->ih_namelen != len || memcmp(he->ih_name, name, len) != 0)
>  		return NULL;
>  	if (time_after(jiffies, he->ih_expires))
> @@ -604,6 +627,8 @@ idmap_lookup_name(struct idmap_hashtable *h, const char *name, size_t len)
>  static inline struct idmap_hashent *
>  idmap_id_hash(struct idmap_hashtable* h, __u32 id)
>  {
> +	if (h->h_entries == NULL)
> +		return NULL;
>  	return &h->h_entries[fnvhash32(&id, sizeof(id)) % IDMAP_HASH_SZ];
>  }
>  
> @@ -611,6 +636,9 @@ static struct idmap_hashent *
>  idmap_lookup_id(struct idmap_hashtable *h, __u32 id)
>  {
>  	struct idmap_hashent *he = idmap_id_hash(h, id);
> +
> +	if (he == NULL)
> +		return NULL;
>  	if (he->ih_id != id || he->ih_namelen == 0)
>  		return NULL;
>  	if (time_after(jiffies, he->ih_expires))
> @@ -626,12 +654,14 @@ idmap_lookup_id(struct idmap_hashtable *h, __u32 id)
>  static inline struct idmap_hashent *
>  idmap_alloc_name(struct idmap_hashtable *h, char *name, size_t len)
>  {
> +	idmap_alloc_hashtable(h);
>  	return idmap_name_hash(h, name, len);
>  }
>  
>  static inline struct idmap_hashent *
>  idmap_alloc_id(struct idmap_hashtable *h, __u32 id)
>  {
> +	idmap_alloc_hashtable(h);
>  	return idmap_id_hash(h, id);
>  }
>  

Much, much better! Nice work.

Built on a different machine this time with a different compiler, so
sizes are a little different. Not certain why, but they're fairly close
-- maybe differences in padding or something:

Without either patch:
(gdb) p sizeof(struct idmap)
$1 = 39168

With just the first patch:
(gdb) p sizeof(struct idmap)
$1 = 8448

With both patches:
(gdb) p sizeof(struct idmap)
$1 = 272


Reviewed-by: Jeff Layton <jlayton@redhat.com>
