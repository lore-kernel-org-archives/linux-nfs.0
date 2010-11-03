Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:55297 "HELO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753303Ab0KCHbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 03:31:18 -0400
Message-ID: <4CD10FC3.7080707@panasas.com>
Date: Wed, 03 Nov 2010 09:31:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Andi Kleen <andi@firstfloor.org>, bjschuma@netapp.com,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [regression] NFS readdir change break fully cached nfs root
References: <20101102180051.GA26089@basil.fritz.box> <1288731930.534.1.camel@heimdal.trondhjem.org>
In-Reply-To: <1288731930.534.1.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-02 23:05, Trond Myklebust wrote:
> On Tue, 2010-11-02 at 19:00 +0100, Andi Kleen wrote:
>> My NFS root test systems stopped booting with 2.6.37-rc1. It just
>> hangs after entering user space.
>>
>> The NFS root setup uses a slightly fancy parameter setup to minimize 
>> network traffic:
>>
>> nfsroot=10.23.204.1:/home/nfsroot/edwin,nocto,acregmin=86400,acregmax=86400,acdirmin=86400,acdirmax=86400 root=/dev/nfs
>>
>> I bisected it down to this commit from Bryan.
>>
>> Unfortunately it's not trivially revertable because that conflicts
>> with later patches.
> 
> Does the following patch help?

This patch helps me too with an infinite readdir loop I've seen
with 2.6.37-rc1.

I'll queue it up in the linux-pnfs tree until it hits upstream.

Benny

> 
> Cheers
>   Trond
> ------------------------------------------------------------------------
> NFS: Fix a couple of regressions in readdir.
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Fix up the issue that array->eof_index needs to be able to be set
> even if array->size == 0.
> 
> Ensure that we catch all important memory allocation error conditions
> and/or kmap() failures.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/dir.c |   73 ++++++++++++++++++++++++++++++++++++++--------------------
>  1 files changed, 48 insertions(+), 25 deletions(-)
> 
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 07ac384..8c22d60 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -194,9 +194,13 @@ typedef struct {
>  static
>  struct nfs_cache_array *nfs_readdir_get_array(struct page *page)
>  {
> +	void *ptr;
>  	if (page == NULL)
>  		return ERR_PTR(-EIO);
> -	return (struct nfs_cache_array *)kmap(page);
> +	ptr = kmap(page);
> +	if (ptr == NULL)
> +		return ERR_PTR(-ENOMEM);
> +	return ptr;
>  }
>  
>  static
> @@ -213,6 +217,9 @@ int nfs_readdir_clear_array(struct page *page, gfp_t mask)
>  {
>  	struct nfs_cache_array *array = nfs_readdir_get_array(page);
>  	int i;
> +
> +	if (IS_ERR(array))
> +		return PTR_ERR(array);
>  	for (i = 0; i < array->size; i++)
>  		kfree(array->array[i].string.name);
>  	nfs_readdir_release_array(page);
> @@ -244,7 +251,7 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
>  
>  	if (IS_ERR(array))
>  		return PTR_ERR(array);
> -	ret = -EIO;
> +	ret = -ENOSPC;
>  	if (array->size >= MAX_READDIR_ARRAY)
>  		goto out;
>  
> @@ -255,9 +262,9 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
>  	if (ret)
>  		goto out;
>  	array->last_cookie = entry->cookie;
> +	array->size++;
>  	if (entry->eof == 1)
>  		array->eof_index = array->size;
> -	array->size++;
>  out:
>  	nfs_readdir_release_array(page);
>  	return ret;
> @@ -272,7 +279,7 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
>  	if (diff < 0)
>  		goto out_eof;
>  	if (diff >= array->size) {
> -		if (array->eof_index > 0)
> +		if (array->eof_index >= 0)
>  			goto out_eof;
>  		desc->current_index += array->size;
>  		return -EAGAIN;
> @@ -281,8 +288,6 @@ int nfs_readdir_search_for_pos(struct nfs_cache_array *array, nfs_readdir_descri
>  	index = (unsigned int)diff;
>  	*desc->dir_cookie = array->array[index].cookie;
>  	desc->cache_entry_index = index;
> -	if (index == array->eof_index)
> -		desc->eof = 1;
>  	return 0;
>  out_eof:
>  	desc->eof = 1;
> @@ -296,17 +301,17 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
>  	int status = -EAGAIN;
>  
>  	for (i = 0; i < array->size; i++) {
> -		if (i == array->eof_index) {
> -			desc->eof = 1;
> -			status = -EBADCOOKIE;
> -		}
>  		if (array->array[i].cookie == *desc->dir_cookie) {
>  			desc->cache_entry_index = i;
>  			status = 0;
> -			break;
> +			goto out;
>  		}
>  	}
> -
> +	if (i == array->eof_index) {
> +		desc->eof = 1;
> +		status = -EBADCOOKIE;
> +	}
> +out:
>  	return status;
>  }
>  
> @@ -449,7 +454,7 @@ out:
>  
>  /* Perform conversion from xdr to cache array */
>  static
> -void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
> +int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
>  				void *xdr_page, struct page *page, unsigned int buflen)
>  {
>  	struct xdr_stream stream;
> @@ -471,21 +476,29 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
>  
>  	do {
>  		status = xdr_decode(desc, entry, &stream);
> -		if (status != 0)
> +		if (status != 0) {
> +			if (status == -EAGAIN)
> +				status = 0;
>  			break;
> +		}
>  
> -		if (nfs_readdir_add_to_array(entry, page) == -1)
> -			break;
>  		if (desc->plus == 1)
>  			nfs_prime_dcache(desc->file->f_path.dentry, entry);
> +
> +		status = nfs_readdir_add_to_array(entry, page);
> +		if (status != 0)
> +			break;
>  	} while (!entry->eof);
>  
>  	if (status == -EBADCOOKIE && entry->eof) {
>  		array = nfs_readdir_get_array(page);
> -		array->eof_index = array->size - 1;
> -		status = 0;
> -		nfs_readdir_release_array(page);
> +		if (!IS_ERR(array)) {
> +			array->eof_index = array->size;
> +			status = 0;
> +			nfs_readdir_release_array(page);
> +		}
>  	}
> +	return status;
>  }
>  
>  static
> @@ -549,9 +562,14 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
>  		goto out;
>  
>  	array = nfs_readdir_get_array(page);
> +	if (IS_ERR(array)) {
> +		status = PTR_ERR(array);
> +		goto out;
> +	}
>  	memset(array, 0, sizeof(struct nfs_cache_array));
>  	array->eof_index = -1;
>  
> +	status = -ENOMEM;
>  	pages_ptr = nfs_readdir_large_page(pages, array_size);
>  	if (!pages_ptr)
>  		goto out_release_array;
> @@ -560,8 +578,13 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
>  
>  		if (status < 0)
>  			break;
> -		nfs_readdir_page_filler(desc, &entry, pages_ptr, page, array_size * PAGE_SIZE);
> -	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
> +		status = nfs_readdir_page_filler(desc, &entry, pages_ptr, page, array_size * PAGE_SIZE);
> +		if (status < 0) {
> +			if (status == -ENOSPC)
> +				status = 0;
> +			break;
> +		}
> +	} while (array->eof_index < 0);
>  
>  	nfs_readdir_free_large_page(pages_ptr, pages, array_size);
>  out_release_array:
> @@ -670,6 +693,8 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
>  	struct dentry *dentry = NULL;
>  
>  	array = nfs_readdir_get_array(desc->page);
> +	if (IS_ERR(array))
> +		return PTR_ERR(array);
>  
>  	for (i = desc->cache_entry_index; i < array->size; i++) {
>  		d_type = DT_UNKNOWN;
> @@ -685,11 +710,9 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
>  			*desc->dir_cookie = array->array[i+1].cookie;
>  		else
>  			*desc->dir_cookie = array->last_cookie;
> -		if (i == array->eof_index) {
> -			desc->eof = 1;
> -			break;
> -		}
>  	}
> +	if (i == array->eof_index)
> +		desc->eof = 1;
>  
>  	nfs_readdir_release_array(desc->page);
>  	cache_page_release(desc);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
