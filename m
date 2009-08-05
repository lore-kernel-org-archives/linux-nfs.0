Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:49209 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932633AbZHEAuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 20:50:24 -0400
Subject: Re: [PATCH v3] read-modify-write page updating
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4A787543.9040701@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
	 <1243963631.4868.124.camel@heimdal.trondhjem.org>
	 <18982.41770.293636.786518@fisica.ufpr.br>
	 <1244049027.5603.5.camel@heimdal.trondhjem.org>
	 <OFB53BFCCB.0CEC7A7E-ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>
	 <1244138698.5203.59.camel@heimdal.trondhjem.org>
	 <4A428482.60403@redhat.com> <4A55FAC8.5040309@redhat.com>
	 <4A787543.9040701@redhat.com>
Content-Type: text/plain
Date: Tue, 04 Aug 2009 20:50:11 -0400
Message-Id: <1249433411.12510.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-08-04 at 13:52 -0400, Peter Staubach wrote:
> Signed-off-by: Peter Staubach <staubach@redhat.com>
> 
> --- linux-2.6.30.i686/fs/nfs/file.c.org
> +++ linux-2.6.30.i686/fs/nfs/file.c
> @@ -328,6 +328,42 @@ nfs_file_fsync(struct file *file, struct
>  }
>  
>  /*
> + * Decide whether a read/modify/write cycle may be more efficient
> + * then a modify/write/read cycle when writing to a page in the
> + * page cache.
> + *
> + * The modify/write/read cycle may occur if a page is read before
> + * being completely filled by the writer.  In this situation, the
> + * page must be completely written to stable storage on the server
> + * before it can be refilled by reading in the page from the server.
> + * This can lead to expensive, small, FILE_SYNC mode writes being
> + * done.
> + *
> + * It may be more efficient to read the page first if the file is
> + * open for reading in addition to writing, the page is not marked
> + * as Uptodate, it is not dirty or waiting to be committed,
> + * indicating that it was previously allocated and then modified,
> + * that there were valid bytes of data in that range of the file,
> + * and that the new data won't completely replace the old data in
> + * that range of the file.
> + */
> +static int nfs_want_read_modify_write(struct file *file, struct page *page,
> +			loff_t pos, unsigned len)
> +{
> +	unsigned int pglen = nfs_page_length(page);
> +	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
> +	unsigned int end = offset + len;
> +
> +	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
> +	    !PageUptodate(page) &&		/* Uptodate? */
> +	    !PagePrivate(page) &&		/* i/o request already? */
> +	    pglen &&				/* valid bytes of file? */
> +	    (end < pglen || offset))		/* replace all valid bytes? */
> +		return 1;
> +	return 0;
> +}
> +
> +/*
>   * This does the "real" work of the write. We must allocate and lock the
>   * page to be sent back to the generic routine, which then copies the
>   * data from user space.
> @@ -340,15 +376,16 @@ static int nfs_write_begin(struct file *
>  			struct page **pagep, void **fsdata)
>  {
>  	int ret;
> -	pgoff_t index;
> +	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
>  	struct page *page;
> -	index = pos >> PAGE_CACHE_SHIFT;
> +	int once_thru = 0;
>  
>  	dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
>  		file->f_path.dentry->d_parent->d_name.name,
>  		file->f_path.dentry->d_name.name,
>  		mapping->host->i_ino, len, (long long) pos);
>  
> +start:
>  	/*
>  	 * Prevent starvation issues if someone is doing a consistency
>  	 * sync-to-disk
> @@ -367,6 +404,13 @@ static int nfs_write_begin(struct file *
>  	if (ret) {
>  		unlock_page(page);
>  		page_cache_release(page);
> +	} else if (!once_thru &&
> +		   nfs_want_read_modify_write(file, page, pos, len)) {
> +		once_thru = 1;
> +		ret = nfs_readpage(file, page);
> +		page_cache_release(page);
> +		if (!ret)
> +			goto start;
>  	}
>  	return ret;
>  }
> 
Thanks! Applied...

Trond

