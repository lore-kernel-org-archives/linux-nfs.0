From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] NFS: Pagecache usage optimization on nfs
Date: Tue, 17 Feb 2009 09:05:52 +0200
Message-ID: <499A61D0.4080100@panasas.com>
References: <6.0.0.20.2.20090217132810.05709598@172.19.0.2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Hisashi Hifumi <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:1655 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751118AbZBQHF5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 02:05:57 -0500
In-Reply-To: <6.0.0.20.2.20090217132810.05709598-+ra6w5dxuwYtxE93JcnU2Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hisashi Hifumi wrote:
> Hi, Trond.
> 
> I wrote "is_partially_uptodate" aops for nfs client named nfs_is_partially_uptodate().
> This aops checks that nfs_page is attached to a page and read IO to a page is 
> within the range between wb_pgbase and wb_pgbase + wb_bytes of the nfs_page. 
> If this aops succeed, we do not have to issue actual read IO to NFS server 
> even if a page is not uptodate because the portion we want to read are uptodate.
> So with this patch random read/write mixed workloads or random read after random write 
> workloads can be optimized and we can get performance improvement.
>  
> I did benchmark test using sysbench.
> 
> sysbench --num-threads=16 --max-requests=100000 --test=fileio --file-block-size=2K 
> --file-total-size=200M --file-test-mode=rndrw --file-fsync-freq=0 
> --file-rw-ratio=0.5 run
> 
> The result was:
> 
> -2.6.29-rc4
> 
> Operations performed:  33356 Read, 66682 Write, 128 Other = 100166 Total
> Read 65.148Mb  Written 130.24Mb  Total transferred 195.39Mb  (3.1093Mb/sec)
>  1591.97 Requests/sec executed
> 
> Test execution summary:
>     total time:                          62.8391s
>     total number of events:              100038
>     total time taken by event execution: 841.7603
>     per-request statistics:
>          min:                            0.0000s
>          avg:                            0.0084s
>          max:                            16.4564s
>          approx.  95 percentile:         0.0446s
> 
> Threads fairness:
>     events (avg/stddev):           6252.3750/306.48
>     execution time (avg/stddev):   52.6100/0.38
> 
> 
> -2.6.29-rc4 + patch
> 
> Operations performed:  33346 Read, 66662 Write, 128 Other = 100136 Total
> Read 65.129Mb  Written 130.2Mb  Total transferred 195.33Mb  (5.0113Mb/sec)
>  2565.81 Requests/sec executed
> 
> Test execution summary:
>     total time:                          38.9772s
>     total number of events:              100008
>     total time taken by event execution: 339.6821
>     per-request statistics:
>          min:                            0.0000s
>          avg:                            0.0034s
>          max:                            1.6768s
>          approx.  95 percentile:         0.0200s
> 
> Threads fairness:
>     events (avg/stddev):           6250.5000/302.04
>     execution time (avg/stddev):   21.2301/0.45
> 
> 
> I/O performance was significantly improved by following patch.
> Please merge my patch.
> Thanks.
> 
> Signed-off-by: Hisashi Hifumi <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
> 
> diff -Nrup linux-2.6.29-rc5.org/fs/nfs/file.c linux-2.6.29-rc5/fs/nfs/file.c
> --- linux-2.6.29-rc5.org/fs/nfs/file.c	2009-02-16 12:31:18.000000000 +0900
> +++ linux-2.6.29-rc5/fs/nfs/file.c	2009-02-16 13:05:29.000000000 +0900
> @@ -449,6 +449,7 @@ const struct address_space_operations nf
>  	.releasepage = nfs_release_page,
>  	.direct_IO = nfs_direct_IO,
>  	.launder_page = nfs_launder_page,
> +	.is_partially_uptodate = nfs_is_partially_uptodate,
>  };
>  
>  static int nfs_vm_page_mkwrite(struct vm_area_struct *vma, struct page *page)
> diff -Nrup linux-2.6.29-rc5.org/fs/nfs/read.c linux-2.6.29-rc5/fs/nfs/read.c
> --- linux-2.6.29-rc5.org/fs/nfs/read.c	2009-02-16 12:31:18.000000000 +0900
> +++ linux-2.6.29-rc5/fs/nfs/read.c	2009-02-16 13:05:29.000000000 +0900
> @@ -599,6 +599,33 @@ out:
>  	return ret;
>  }
>  
> +int nfs_is_partially_uptodate(struct page *page, read_descriptor_t *desc,
> +				unsigned long from)
> +{
> +	struct inode *inode = page->mapping->host;
> +	unsigned to;
> +	struct nfs_page *req = NULL;
+	int ret;
> +
> +	spin_lock(&inode->i_lock);
> +	if (PagePrivate(page)) {
> +		req = (struct nfs_page *)page_private(page);
> +		if (req)
> +			kref_get(&req->wb_kref);
> +	}
> +	spin_unlock(&inode->i_lock);
> +	if (!req)
> +		return 0;
> +
> +	to = min_t(unsigned, PAGE_CACHE_SIZE - from, desc->count);
> +	to = from + to;
> +	if (from >= req->wb_pgbase && to <= req->wb_pgbase + req->wb_bytes) {
> +		nfs_release_request(req);
-		nfs_release_request(req);
> +		ret = 1;
> +	} else
+		ret = 0;
> +	nfs_release_request(req);
> +	return 0;
-	return 0;
+	return ret;
> +}
> +
>  int __init nfs_init_readpagecache(void)
>  {
>  	nfs_rdata_cachep = kmem_cache_create("nfs_read_data",
> diff -Nrup linux-2.6.29-rc5.org/include/linux/nfs_fs.h linux-2.6.29-rc5/include/linux/nfs_fs.h
> --- linux-2.6.29-rc5.org/include/linux/nfs_fs.h	2009-02-16 12:31:18.000000000 +0900
> +++ linux-2.6.29-rc5/include/linux/nfs_fs.h	2009-02-16 13:05:29.000000000 +0900
> @@ -506,6 +506,9 @@ extern int  nfs_readpages(struct file *,
>  		struct list_head *, unsigned);
>  extern int  nfs_readpage_result(struct rpc_task *, struct nfs_read_data *);
>  extern void nfs_readdata_release(void *data);
> +extern int  nfs_is_partially_uptodate(struct page *, read_descriptor_t *,
> +		unsigned long);
> +
>  
>  /*
>   * Allocate nfs_read_data structures
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

