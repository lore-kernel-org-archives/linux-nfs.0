Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7278 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab1DVJJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 05:09:24 -0400
Message-ID: <4DB145C0.9030601@panasas.com>
Date: Fri, 22 Apr 2011 12:09:20 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 12/27] pnfs: alloc and free layout_hdr layoutdriver methods
References: <4DAF0DE1.6020609@panasas.com>	 <1303320468-21407-1-git-send-email-bhalevy@panasas.com> <1303332231.23206.49.camel@lade.trondhjem.org>
In-Reply-To: <1303332231.23206.49.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 23:43, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:27 +0300, Benny Halevy wrote:
> 
> Why is this needed?
> 

for allocating layout-driver private data in hdr.
I'll re-send with the usage...

>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/pnfs.c |   21 ++++++++++++++++++---
>>  fs/nfs/pnfs.h |    3 +++
>>  2 files changed, 21 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index afc64b3..2254362 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -188,13 +188,28 @@ get_layout_hdr(struct pnfs_layout_hdr *lo)
>>  	atomic_inc(&lo->plh_refcount);
>>  }
>>  
>> +static struct pnfs_layout_hdr *
>> +pnfs_alloc_layout_hdr(struct inode *ino)
>> +{
>> +	struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
>> +	return ld->alloc_layout_hdr ? ld->alloc_layout_hdr(ino) :
>> +		kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
> 
> BTW: GFP_KERNEL is a bug here. It should be GFP_NOFS or else we can
> recurse back into the filesystem through the page reclaim code.
> 

OK.  then this needs to be fixed upstream as well
in alloc_init_layout_hdr().

Should I send a patch?

Benny

>> +}
>> +
>> +static void
>> +pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
>> +{
>> +	struct pnfs_layoutdriver_type *ld = NFS_SERVER(lo->plh_inode)->pnfs_curr_ld;
>> +	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
>> +}
>> +
>>  static void
>>  destroy_layout_hdr(struct pnfs_layout_hdr *lo)
>>  {
>>  	dprintk("%s: freeing layout cache %p\n", __func__, lo);
>>  	BUG_ON(!list_empty(&lo->plh_layouts));
>>  	NFS_I(lo->plh_inode)->layout = NULL;
>> -	kfree(lo);
>> +	pnfs_free_layout_hdr(lo);
>>  }
>>  
>>  static void
>> @@ -857,7 +872,7 @@ alloc_init_layout_hdr(struct inode *ino)
>>  {
>>  	struct pnfs_layout_hdr *lo;
>>  
>> -	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
>> +	lo = pnfs_alloc_layout_hdr(ino);
>>  	if (!lo)
>>  		return NULL;
>>  	atomic_set(&lo->plh_refcount, 1);
>> @@ -890,7 +905,7 @@ pnfs_find_alloc_layout(struct inode *ino)
>>  	if (likely(nfsi->layout == NULL))	/* Won the race? */
>>  		nfsi->layout = new;
>>  	else
>> -		kfree(new);
>> +		pnfs_free_layout_hdr(new);
>>  	return nfsi->layout;
>>  }
>>  
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index bb266ba..35662ac 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -83,6 +83,9 @@ struct pnfs_layoutdriver_type {
>>  	int (*set_layoutdriver) (struct nfs_server *);
>>  	int (*unset_layoutdriver) (struct nfs_server *);
>>  
>> +	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode);
>> +	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
>> +
>>  	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
>>  	void (*free_lseg) (struct pnfs_layout_segment *lseg);
>>  
> 
> 

