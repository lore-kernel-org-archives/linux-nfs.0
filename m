Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756351Ab2BHMEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 07:04:12 -0500
Date: Wed, 8 Feb 2012 07:04:08 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key()
 fails
Message-ID: <20120208070408.6f77544d@tlielax.poochiereds.net>
In-Reply-To: <1328645155.4124.44.camel@lade.trondhjem.org>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
	<20120207141254.2948e735@tlielax.poochiereds.net>
	<1328642485.4124.40.camel@lade.trondhjem.org>
	<4F317BA1.4050102@netapp.com>
	<1328643867.4124.42.camel@lade.trondhjem.org>
	<1328645155.4124.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Feb 2012 20:05:55 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-02-07 at 14:44 -0500, Trond Myklebust wrote:
> 
> > One way to easily shrink the size of that allocation is to convert the
> > ih_name string into a pointer, and have the downcall allocate the
> > storage for that string dynamically...
> 
> Like so....
> 

Nice. I had started looking at this, but was still sorting my way
through how all of the hashtable cache code works.

One comment inline below:

> 8<-----------------------------------------------------------------------
> From 5221c8415957604507cd7408a695241096bcb3ad Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 7 Feb 2012 14:59:05 -0500
> Subject: [PATCH] NFSv4: Reduce the footprint of the idmapper
> 
> Instead of pre-allocating the storage for all the strings, we can
> significantly reduce the size of that table by doing the allocation
> when we do the downcall.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/idmap.c |   16 +++++++++++++---
>  1 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 5a5566f..fff7948 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -362,7 +362,7 @@ struct idmap_hashent {
>  	unsigned long		ih_expires;
>  	__u32			ih_id;
>  	size_t			ih_namelen;
> -	char			ih_name[IDMAP_NAMESZ];
> +	const char		*ih_name;
>  };
>  
>  struct idmap_hashtable {
> @@ -482,12 +482,17 @@ void
>  nfs_idmap_delete(struct nfs_client *clp)
>  {
>  	struct idmap *idmap = clp->cl_idmap;
> +	int i;
>  
>  	if (!idmap)
>  		return;
>  	nfs_idmap_unregister(clp, idmap->idmap_pipe);
>  	rpc_destroy_pipe_data(idmap->idmap_pipe);
>  	clp->cl_idmap = NULL;
> +	for (i = 0; i < ARRAY_SIZE(idmap->idmap_user_hash.h_entries); i++)
> +		kfree(idmap->idmap_user_hash.h_entries[i].ih_name);
> +	for (i = 0; i < ARRAY_SIZE(idmap->idmap_group_hash.h_entries); i++)
> +		kfree(idmap->idmap_group_hash.h_entries[i].ih_name);
>  	kfree(idmap);
>  }
>  
> @@ -634,9 +639,14 @@ static void
>  idmap_update_entry(struct idmap_hashent *he, const char *name,
>  		size_t namelen, __u32 id)
>  {
> +	char *str = kmalloc(namelen + 1, GFP_KERNEL);

Do we need to worry about recursing into direct reclaim here?

> +	if (str == NULL)
> +		return;
> +	kfree(he->ih_name);
>  	he->ih_id = id;
> -	memcpy(he->ih_name, name, namelen);
> -	he->ih_name[namelen] = '\0';
> +	memcpy(str, name, namelen);
> +	str[namelen] = '\0';
> +	he->ih_name = str;
>  	he->ih_namelen = namelen;
>  	he->ih_expires = jiffies + nfs_idmap_cache_timeout;
>  }

...and the namelen check in idmap_lookup_name should keep the memcmp
from tripping over these NULL pointers. I think this looks like a nice
interim fix for now and should cut down on the memory consumption from
this code.

On a x86_64 machine:

pre-patch:
(gdb) p sizeof(struct idmap)
$1 = 39504

post-patch:
(gdb) p sizeof(struct idmap)
$1 = 8784

That changes this from an order 4 to an order 2 allocation. Would be
even nicer to get it down to under a page, but this will help
considerably.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
