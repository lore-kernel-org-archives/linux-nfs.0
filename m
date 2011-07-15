Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:41542 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964Ab1GOLQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jul 2011 07:16:51 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 10/10] nfs: debugging for nfs destructor
Date: Fri, 15 Jul 2011 12:07:11 +0100
Message-ID: <1310728031-19569-10-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

---
 fs/nfs/direct.c            |   57 +++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs3xdr.c           |    2 +
 include/linux/mm.h         |    4 +++
 include/linux/page-flags.h |    2 +
 mm/swap.c                  |    6 ++++
 net/core/skbuff.c          |   14 ++++++++++-
 net/sunrpc/svcsock.c       |    7 +++++
 net/sunrpc/xdr.c           |   12 ++++++++-
 net/sunrpc/xprtsock.c      |    8 ++++++
 9 files changed, 109 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 4735fd9..9512f75 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -144,8 +144,12 @@ static void nfs_direct_dirty_pages(struct page **pages, unsigned int pgbase, siz
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
-	for (i = 0; i < npages; i++)
+	for (i = 0; i < npages; i++) {
+		if (0) printk(KERN_CRIT "%s releasing %p (clearing debug)\n",
+		       __func__, pages[i]);
+		ClearPageDebug(pages[i]);
 		page_cache_release(pages[i]);
+	}
 }
 
 static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
@@ -216,6 +220,8 @@ out:
  */
 static void nfs_direct_complete(struct nfs_direct_req *dreq)
 {
+	if (0) printk(KERN_CRIT "%s for dreq:%p count:%d\n",
+	       __func__, dreq, atomic_read(&dreq->io_count));
 	if (dreq->iocb) {
 		long res = (long) dreq->error;
 		if (!res)
@@ -521,6 +527,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 				(unsigned long long)data->args.offset);
 	}
 
+	if (0) printk(KERN_CRIT "%s for w:%p dreq:%p count:%d\n", __func__,
+	       data, dreq, atomic_read(&dreq->io_count));
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, inode);
 }
@@ -549,6 +557,8 @@ static void nfs_direct_commit_release(void *calldata)
 	}
 
 	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
+	if (0) printk(KERN_CRIT "%s for w:%p dreq:%p count:%d\n", __func__,
+	       data, dreq, atomic_read(&dreq->io_count));
 	nfs_direct_write_complete(dreq, data->inode);
 	nfs_commit_free(data);
 }
@@ -609,20 +619,25 @@ static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode
 {
 	int flags = dreq->flags;
 
+	if (0) printk(KERN_CRIT "%s for dreq:%p\n", __func__, dreq);
 	dreq->flags = 0;
 	switch (flags) {
 		case NFS_ODIRECT_DO_COMMIT:
+			if (0) printk(KERN_CRIT "%s: DO_COMMIT\n", __func__);
 			nfs_direct_commit_schedule(dreq);
 			break;
 		case NFS_ODIRECT_RESCHED_WRITES:
+			if (0) printk(KERN_CRIT "%s: RESCHED\n", __func__);
 			nfs_direct_write_reschedule(dreq);
 			break;
 		default:
+			if (0) printk(KERN_CRIT "%s: DONE\n", __func__);
 			if (dreq->commit_data != NULL)
 				nfs_commit_free(dreq->commit_data);
 			nfs_direct_free_writedata(dreq);
 			nfs_zap_mapping(inode, inode->i_mapping);
 			nfs_direct_complete(dreq);
+			//set_all_pages_debug(data->pagevec, data->npages);
 	}
 }
 
@@ -661,6 +676,7 @@ static void nfs_direct_write_release(void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+
 	int status = data->task.tk_status;
 
 	spin_lock(&dreq->lock);
@@ -691,6 +707,8 @@ static void nfs_direct_write_release(void *calldata)
 out_unlock:
 	spin_unlock(&dreq->lock);
 
+	if (0) printk(KERN_CRIT "%s for w:%p dreq:%p count:%d\n", __func__,
+	       data, dreq, atomic_read(&dreq->io_count));
 	skb_frag_destructor_unref(data->args.pages_destructor);
 }
 
@@ -706,11 +724,29 @@ static int nfs_write_page_destroy(void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	//int i;
+	if (0) printk(KERN_CRIT "%s for w:%p dreq:%p count:%d\n", __func__,
+	       data, dreq,
+	       atomic_read(&dreq->io_count));
+	//for (i = 0; i < data->npages; i++)
+	//	put_page(data->pagevec[i]);
+
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, data->inode);
 	return 0;
 }
 
+static void set_all_pages_debug(struct page **pages, int npages)
+{
+	int i;
+	return;
+	for (i=0; i<npages; i++) {
+		if (0) printk(KERN_CRIT "Marking page %p as debug current count:%d\n",
+		       pages[i],page_count(pages[i]));
+		SetPageDebug(pages[i]);
+	}
+}
+
 /*
  * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
  * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
@@ -754,6 +790,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		if (unlikely(!data))
 			break;
 
+		if (0) printk(KERN_CRIT "%s: getting user pages\n", __func__);
 		down_read(&current->mm->mmap_sem);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
@@ -773,6 +810,8 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 			data->npages = result;
 		}
 
+		set_all_pages_debug(data->pagevec, data->npages);
+
 		get_dreq(dreq);
 
 		list_move_tail(&data->pages, &dreq->rewrite_list);
@@ -790,7 +829,11 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
+#if 1
 		data->args.pages_destructor = &data->pagevec_destructor;
+#else
+		data->args.pages_destructor = NULL;
+#endif
 		data->args.count = bytes;
 		data->args.stable = sync;
 		data->res.fattr = &data->fattr;
@@ -804,6 +847,16 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		msg.rpc_resp = &data->res;
 		NFS_PROTO(inode)->write_setup(data, &msg);
 
+		if (0) printk(KERN_CRIT "%s scheduling w:%p dreq:%p count:%d. args %p pages:%d dest:%p %pf\n",
+		       __func__, data, dreq,
+		       atomic_read(&dreq->io_count),
+		       &data->args, data->npages,
+		       data->args.pages_destructor,
+		       data->args.pages_destructor->destroy);
+		if (0) printk(KERN_CRIT "%s page[0] is %p count:%d\n",
+		       __func__, data->pagevec[0],
+		       page_count(data->pagevec[0]));
+
 		task = rpc_run_task(&task_setup_data);
 		if (IS_ERR(task))
 			break;
@@ -866,6 +919,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		return result < 0 ? result : -EIO;
 	}
 
+	if (0) printk(KERN_CRIT "%s for dreq:%p count:%d\n", __func__,
+	       dreq, atomic_read(&dreq->io_count));
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, dreq->inode);
 	return 0;
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index f7a83a1..2137550 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -994,6 +994,8 @@ static void encode_write3args(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->count);
 	*p++ = cpu_to_be32(args->stable);
 	*p = cpu_to_be32(args->count);
+	if (0) printk(KERN_CRIT "%s xdr %p args %p destructor %pF\n",
+	       __func__, xdr, args, args->pages_destructor->destroy);
 	xdr_write_pages(xdr, args->pages, args->pages_destructor,
 			args->pgbase, args->count);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 550ec8f..f992dfa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -362,6 +362,10 @@ static inline int page_count(struct page *page)
 
 static inline void get_page(struct page *page)
 {
+	if (PageDebug(page)) printk(KERN_CRIT "%s(%p) from %pF count %d\n",
+				    __func__, page,
+				    __builtin_return_address(0),
+				    page_count(page));
 	/*
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_count. Only if
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 7d632cc..8434345 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -107,6 +107,7 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+	PG_debug,
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -209,6 +210,7 @@ PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
 PAGEFLAG(SavePinned, savepinned);			/* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
+PAGEFLAG(Debug, debug)
 
 __PAGEFLAG(SlobFree, slob_free)
 
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..4450105 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -61,6 +61,8 @@ static void __page_cache_release(struct page *page)
 
 static void __put_single_page(struct page *page)
 {
+	if (PageDebug(page)) printk(KERN_CRIT "%s(%p) from %pF\n", __func__, page, __builtin_return_address(0));
+	ClearPageDebug(page);
 	__page_cache_release(page);
 	free_hot_cold_page(page, 0);
 }
@@ -153,6 +155,10 @@ static void put_compound_page(struct page *page)
 
 void put_page(struct page *page)
 {
+	if (PageDebug(page)) printk(KERN_CRIT "%s(%p) from %pF count %d\n",
+				    __func__, page,
+				    __builtin_return_address(0),
+				    page_count(page));
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
 	else if (put_page_testzero(page))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bdc6f6e..c3fdfb7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -296,6 +296,9 @@ void skb_frag_destructor_ref(struct skb_frag_destructor *destroy)
 {
 	BUG_ON(destroy == NULL);
 	atomic_inc(&destroy->ref);
+	if (0) printk(KERN_CRIT "%s from %pF: %d\n",
+	       __func__, __builtin_return_address(0),
+	       atomic_read(&destroy->ref));
 }
 EXPORT_SYMBOL(skb_frag_destructor_ref);
 
@@ -304,8 +307,17 @@ void skb_frag_destructor_unref(struct skb_frag_destructor *destroy)
 	if (destroy == NULL)
 		return;
 
-	if (atomic_dec_and_test(&destroy->ref))
+	if (atomic_dec_and_test(&destroy->ref)) {
+		if (0) printk(KERN_CRIT "%s from %pF: calling destructor %p %pf(%p)\n",
+		       __func__, __builtin_return_address(0),
+		       destroy, destroy->destroy, destroy->data);
 		destroy->destroy(destroy->data);
+	} else {
+		if (0) printk(KERN_CRIT "%s from %pF: destructor %p %pf(%p) not called %d remaining\n",
+		       __func__, __builtin_return_address(0),
+		       destroy, destroy->destroy, destroy->data,
+		       atomic_read(&destroy->ref));
+	}
 }
 EXPORT_SYMBOL(skb_frag_destructor_unref);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 40c2420..64ce9907 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -176,6 +176,10 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	int		slen;
 	int		len = 0;
 
+	if (xdr->destructor)
+		if (0) printk(KERN_CRIT "%s sending xdr %p with destructor %pF\n",
+		       __func__, xdr, xdr->destructor->destroy);
+
 	slen = xdr->len;
 
 	/* send head */
@@ -194,6 +198,9 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
+		if (xdr->destructor)
+			if (0) printk(KERN_CRIT "%s sending xdr %p page %p with destructor %pF\n",
+			       __func__, xdr, *ppage, xdr->destructor);
 		result = kernel_sendpage(sock, *ppage, xdr->destructor, base, size, flags);
 		if (result > 0)
 			len += result;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 9c7dded..fcaea6a 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -135,6 +135,10 @@ xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
 	struct kvec *tail = xdr->tail;
 	u32 *p;
 
+	if (xdr->destructor)
+		if (0) printk(KERN_CRIT "%s xdr %p with destructor %p\n",
+		       __func__, xdr, xdr->destructor);
+
 	xdr->pages = pages;
 	xdr->page_base = base;
 	xdr->page_len = len;
@@ -165,6 +169,11 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 	char *buf = (char *)head->iov_base;
 	unsigned int buflen = head->iov_len;
 
+
+	if (xdr->destructor)
+		if (0) printk(KERN_CRIT "%s xdr %p with destructor %p\n",
+		       __func__, xdr, xdr->destructor);
+
 	head->iov_len  = offset;
 
 	xdr->pages = pages;
@@ -535,7 +544,8 @@ void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
 	buf->destructor = destroy;
 	buf->page_base = base;
 	buf->page_len = len;
-
+	if (destroy)
+		if (0) printk(KERN_CRIT "%s xdr %p %p destructor %p\n", __func__, xdr, buf, destroy);
 	iov->iov_base = (char *)xdr->p;
 	iov->iov_len  = 0;
 	xdr->iov = iov;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index aa31294..336d787 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -386,6 +386,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 	unsigned int remainder;
 	int err, sent = 0;
 
+	if (xdr->destructor)
+		if (0) printk(KERN_CRIT "%s sending xdr %p with destructor %pF\n",
+		       __func__, xdr, xdr->destructor->destroy);
+
 	remainder = xdr->page_len - base;
 	base += xdr->page_base;
 	ppage = xdr->pages + (base >> PAGE_SHIFT);
@@ -425,6 +429,10 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	unsigned int remainder = xdr->len - base;
 	int err, sent = 0;
 
+	if (xdr->destructor)
+		if (0) printk(KERN_CRIT "%s sending xdr %p with destructor %pF\n",
+		       __func__, xdr, xdr->destructor->destroy);
+
 	if (unlikely(!sock))
 		return -ENOTSOCK;
 
-- 
1.7.2.5

