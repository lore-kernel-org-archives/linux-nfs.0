Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E24DC43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 05:48:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 593292087F
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 05:48:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726264AbfADFsB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Jan 2019 00:48:01 -0500
Received: from out30-131.freemail.mail.aliyun.com ([115.124.30.131]:43270 "EHLO
        out30-131.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726093AbfADFsB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2019 00:48:01 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0THV54pr_1546580816;
Received: from 30.5.116.68(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0THV54pr_1546580816)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 04 Jan 2019 13:46:57 +0800
Subject: Re: [PATCH] NFS: readdirplus optimization by cache mechanism
From:   =?UTF-8?B?5Lmx55+z?= <zhangliguang@linux.alibaba.com>
To:     linux-nfs@vger.kernel.org
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
References: <1546580095-125450-1-git-send-email-zhangliguang@linux.alibaba.com>
Message-ID: <b84bdb4d-4422-6f46-a5f8-e5cf0496173e@linux.alibaba.com>
Date:   Fri, 4 Jan 2019 13:46:56 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1546580095-125450-1-git-send-email-zhangliguang@linux.alibaba.com>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Sorry for this letter£¬ I will send RFC v1 instead.

ÔÚ 2019/1/4 13:34, zhangliguang Ð´µÀ:
> When listing very large directories via NFS, clients may take a long
> time to complete. There are about three factors involved:
>
> First of all, ls and practically every other method of listing a
> directory including python os.listdir and find rely on libc readdir().
> However readdir() only reads 32K of directory entries at a time, which
> means that if you have a lot of files in the same directory, it is going
> to take an insanely long time to read all the directory entries.
>
> Secondly, libc readdir() reads 32K of directory entries at a time, in
> kernel space 32K buffer split into 8 pages. One NFS readdirplus rpc will
> be called for one page, which introduces many readdirplus rpc calls.
>
> Lastly, one NFS readdirplus rpc asks for 32K data (filled by nfs_dentry)
> to fill one page (filled by dentry), we found that nearly one third of
> data was wasted.
>
> To solve above problems, pagecache mechanism was introduced. One NFS
> readdirplus rpc will ask for a large data (more than 32k), the data can
> fill more than one page, the cached pages can be used for next readdir
> call. This can reduce many readdirplus rpc calls and improve readdirplus
> performance.
>
> TESTING:
> When listing very large directories(include 300 thousand files) via NFS
>
> time ls -l /nfs_mount | wc -l
>
> without the patch:
> 300001
> real    1m53.524s
> user    0m2.314s
> sys     0m2.599s
>
> with the patch:
> 300001
> real    0m23.487s
> user    0m2.305s
> sys     0m2.558s
>
> Improved performance: 79.6%
> readdirplus rpc calls decrease: 85%
>
> Signed-off-by: Liguang Zhang <zhangliguang@linux.alibaba.com>
> ---
>   fs/nfs/dir.c      | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++---
>   fs/nfs/internal.h |   3 ++
>   2 files changed, 111 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 6bf4471..8b80c02 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -139,12 +139,19 @@ struct nfs_cache_array {
>   	struct nfs_cache_array_entry array[0];
>   };
>   
> +struct readdirvec {
> +	unsigned long nr;
> +	unsigned long index;
> +	struct page *pages[NFS_MAX_READDIR_RAPAGES];
> +};
> +
>   typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, bool);
>   typedef struct {
>   	struct file	*file;
>   	struct page	*page;
>   	struct dir_context *ctx;
>   	unsigned long	page_index;
> +	struct readdirvec pvec;
>   	u64		*dir_cookie;
>   	u64		last_cookie;
>   	loff_t		current_index;
> @@ -524,6 +531,11 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
>   	struct nfs_cache_array *array;
>   	unsigned int count = 0;
>   	int status;
> +	int max_rapages = NFS_MAX_READDIR_RAPAGES;
> +	void *src, *dst;
> +
> +	desc->pvec.index = desc->page_index;
> +	desc->pvec.nr = 0;
>   
>   	scratch = alloc_page(GFP_KERNEL);
>   	if (scratch == NULL)
> @@ -548,20 +560,45 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
>   		if (desc->plus)
>   			nfs_prime_dcache(file_dentry(desc->file), entry);
>   
> -		status = nfs_readdir_add_to_array(entry, page);
> +		status = nfs_readdir_add_to_array(entry, desc->pvec.pages[desc->pvec.nr]);
> +		if (status == -ENOSPC) {
> +			desc->pvec.nr++;
> +			if (desc->pvec.nr == max_rapages)
> +				break;
> +			status = nfs_readdir_add_to_array(entry, desc->pvec.pages[desc->pvec.nr]);
> +		}
> +
>   		if (status != 0)
>   			break;
>   	} while (!entry->eof);
>   
> +	/*
> +	 * page and desc->pvec.pages[0] are valid, don't need to check
> +	 * whether or not to be NULL.
> +	 */
> +	dst = kmap(page);
> +	src = kmap(desc->pvec.pages[0]);
> +	memcpy(dst, src, PAGE_SIZE);
> +	kunmap(dst);
> +	kunmap(src);
> +
>   out_nopages:
>   	if (count == 0 || (status == -EBADCOOKIE && entry->eof != 0)) {
> -		array = kmap(page);
> +		array = kmap(desc->pvec.pages[desc->pvec.nr]);
>   		array->eof_index = array->size;
>   		status = 0;
> -		kunmap(page);
> +		kunmap(desc->pvec.pages[desc->pvec.nr]);
>   	}
>   
>   	put_page(scratch);
> +
> +	/*
> +	 * desc->pvec.nr > 0 means at least one page was completely filled,
> +	 * we should return -ENOSPC. Otherwise function
> +	 * nfs_readdir_xdr_to_array will enter infinite loop.
> +	 */
> +	if (desc->pvec.nr > 0)
> +		return -ENOSPC;
>   	return status;
>   }
>   
> @@ -604,6 +641,30 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
>   	struct nfs_cache_array *array;
>   	int status = -ENOMEM;
>   	unsigned int array_size = ARRAY_SIZE(pages);
> +	int max_rapages = NFS_MAX_READDIR_RAPAGES;
> +	int page_index;
> +
> +	/*
> +	 * This means we hit readdir rdpages miss, the preallocated rdpages
> +	 * are useless, we should release the preallocate rdpages first, and
> +	 * then alloc pages for the next readdir.
> +	 */
> +	nfs_readdir_free_pages(desc->pvec.pages, max_rapages);
> +
> +	status = nfs_readdir_alloc_pages(desc->pvec.pages, max_rapages);
> +	if (status < 0)
> +		return -ENOMEM;
> +
> +	for (page_index = 0; page_index < max_rapages; page_index++) {
> +		array = kmap(desc->pvec.pages[page_index]);
> +		if (IS_ERR(array)) {
> +			status = PTR_ERR(array);
> +			return status;
> +		}
> +		memset(array, 0, sizeof(struct nfs_cache_array));
> +		array->eof_index = -1;
> +		kunmap(desc->pvec.pages[page_index]);
> +	}
>   
>   	entry.prev_cookie = 0;
>   	entry.cookie = desc->last_cookie;
> @@ -663,10 +724,30 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
>   {
>   	struct inode	*inode = file_inode(desc->file);
>   	int ret;
> +	void *dst, *src;
> +	unsigned long end_index = desc->pvec.index + desc->pvec.nr;
> +
> +	/*
> +	 * If desc->page_index in range desc->pvec.index and
> +	 * desc->pvec.index + desc->pvec.nr, we get readdir cache hit.
> +	 */
> +	if ((desc->page_index >= desc->pvec.index) && (desc->page_index < end_index)) {
> +		/*
> +		 * page and desc->pvec.pages[x] are valid, don't need to check
> +		 * whether or not to be NULL.
> +		 */
> +		dst = kmap(page);
> +		src = kmap(desc->pvec.pages[desc->page_index - desc->pvec.index]);
> +		memcpy(dst, src, PAGE_SIZE);
> +		kunmap(dst);
> +		kunmap(src);
> +		ret = 0;
> +	} else {
> +		ret = nfs_readdir_xdr_to_array(desc, page, inode);
> +		if (ret < 0)
> +			goto error;
> +	}
>   
> -	ret = nfs_readdir_xdr_to_array(desc, page, inode);
> -	if (ret < 0)
> -		goto error;
>   	SetPageUptodate(page);
>   
>   	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
> @@ -831,6 +912,10 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
>   			*desc = &my_desc;
>   	struct nfs_open_dir_context *dir_ctx = file->private_data;
>   	int res = 0;
> +	struct nfs_cache_array *array;
> +	int max_rapages = NFS_MAX_READDIR_RAPAGES;
> +	int status;
> +	int page_index;
>   
>   	dfprintk(FILE, "NFS: readdir(%pD2) starting at cookie %llu\n",
>   			file, (long long)ctx->pos);
> @@ -850,6 +935,21 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
>   	desc->decode = NFS_PROTO(inode)->decode_dirent;
>   	desc->plus = nfs_use_readdirplus(inode, ctx);
>   
> +	status = nfs_readdir_alloc_pages(desc->pvec.pages, max_rapages);
> +	if (status < 0)
> +		return -ENOMEM;
> +
> +	for (page_index = 0; page_index < max_rapages; page_index++) {
> +		array = kmap(desc->pvec.pages[page_index]);
> +		if (IS_ERR(array)) {
> +			status = PTR_ERR(array);
> +			goto out_pages_free;
> +		}
> +		memset(array, 0, sizeof(struct nfs_cache_array));
> +		array->eof_index = -1;
> +		kunmap(desc->pvec.pages[page_index]);
> +	}
> +
>   	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
>   		res = nfs_revalidate_mapping(inode, file->f_mapping);
>   	if (res < 0)
> @@ -884,6 +984,8 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
>   		if (res < 0)
>   			break;
>   	} while (!desc->eof);
> +out_pages_free:
> +	nfs_readdir_free_pages(desc->pvec.pages, max_rapages);
>   out:
>   	if (res > 0)
>   		res = 0;
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 7f80f03..132ffc7 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -71,6 +71,9 @@ struct nfs_clone_mount {
>    */
>   #define NFS_MAX_READDIR_PAGES 8
>   
> +/* Maximum number of pages that readdir can readahead. */
> +#define NFS_MAX_READDIR_RAPAGES 8
> +
>   struct nfs_client_initdata {
>   	unsigned long init_flags;
>   	const char *hostname;			/* Hostname of the server */
