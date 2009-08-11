From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NULL pointer dereference in __put_nfs_open_context()
Date: Tue, 11 Aug 2009 08:58:50 -0400
Message-ID: <1249995530.12218.3.camel@heimdal.trondhjem.org>
References: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754608AbZHKM65@vger.kernel.org>
In-Reply-To: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-11 at 12:38 +0100, Catalin Marinas wrote:
> Hi,
> 
> While running LTP on 2.6.31-rc5 (plus some additional patches but not
> related to NFS) on an ARM platform with the root filesystem over NFS I
> get the oops below with diotest4 (in testcases/kernel/io/direct_io/):
> 
> 
> Unable to handle kernel NULL pointer dereference at virtual address 00000008
> pgd = cc3bc000 [00000008] *pgd=7b0bf031st4, *pte=00000000:  Out of range 
> Internal error: Oops: 17 [#6] PREEMPT
> Modules linked in:
> CPU: 0    Tainted: G      D     (2.6.31-rc5 #285)
> PC is at __put_nfs_open_context+0x4/0x68
> LR is at put_nfs_open_context+0x9/0xc
> pc : [<c00e3c0c>]    lr : [<c00e3cc5>]    psr: 60000033
> sp : de63fda0  ip : cb0bb800  fp : c3dca110
> r10: 00000000  r9 : de63ff48  r8 : fffffff2
> r7 : dad86348  r6 : 00001000  r5 : 00000000  r4 : d7f971e0
> r3 : 00000000  r2 : de63fda0  r1 : 00000000  r0 : 00000000
> Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA Thumb  Segment user
> Control: 70c5387d  Table: 7c3bc019  DAC: 00000015
> Process diotest4 (pid: 12915, stack limit = 0xde63e2f0)
> Stack: (0xde63fda0 to 0xde640000)
> fda0: d7f971e0 00000000 00001000 dad86348 fffffff2 c00e3cc5 d7f971e0 c00e9459 
> fdc0: d7f971e0 c00e7aa5 00000001 00000000 d7f9735c 00000000 cc3c6b70 c010fd6d 
> fde0: 00000001 de63feb8 00000000 00000000 c3dca000 c3dca008 de63e000 00001000 
> fe00: 00001000 40044000 c292da80 de63ff4c 00001000 00000000 00001000 00000000 
> fe20: 00000026 00000000 df343440 de63fe40 c02089b0 00000000 df9fc200 00000001 
> fe40: 00000000 00000000 00000000 df2eec80 c3dca110 c3da84b0 deee0c40 00001000 
> fe60: de63feb8 00001000 de63ff48 00000001 c3dca110 c00e2a1b 00001000 00000000 
> fe80: 00000000 00000000 00000000 de63feb8 deee0c40 de63ff80 00001000 de63ff80 
> fea0: de63e000 00000000 00000fff c0075049 00001000 00000000 de72c000 00000001 
> fec0: 00000000 00000001 ffffffff deee0c40 00000000 00000000 00000000 00000000 
> fee0: df32b600 df801f00 00000000 00000000 de72b0c0 df32b600 c004467d de63fefc 
> ff00: de63fefc c0070bef 00001000 00000000 00000018 c0c65500 de72c0d8 c0073ebb 
> ff20: 00001000 c0070f33 de63e000 c0c65500 df801f00 c0071047 df801f00 00001000 
> ff40: 00000000 deee0c40 40044000 00001000 deee0c40 c0074fe1 40044000 c00759a1 
> ff60: deee0c40 40044000 deee0c40 40044000 00001000 00000000 00001000 c0075acd 
> ff80: 00001000 00000000 00001000 00000000 fffff000 00001000 00000004 00000003 
> ffa0: c0027e08 c0027c41 fffff000 00001000 00000004 40044000 00001000 00001000 
> ffc0: fffff000 00001000 00000004 00000003 fffff000 0001a000 00000001 00000fff 
> ffe0: 00000002 bebbfb68 0000a228 400e3c0c 60000010 00000004 00000000 00000000 
> [<c00e3c0c>] (__put_nfs_open_context+0x4/0x68) from [<c00e3cc5>] (put_nfs_open_context+0x9/0xc)
> [<c00e3cc5>] (put_nfs_open_context+0x9/0xc) from [<c00e9459>] (nfs_readdata_release+0xd/0x14)
> [<c00e9459>] (nfs_readdata_release+0xd/0x14) from [<c00e7aa5>] (nfs_file_direct_read+0x261/0x438)
> [<c00e7aa5>] (nfs_file_direct_read+0x261/0x438) from [<c00e2a1b>] (nfs_file_read+0x4b/0xdc)
> [<c00e2a1b>] (nfs_file_read+0x4b/0xdc) from [<c0075049>] (do_sync_read+0x69/0x98)
> [<c0075049>] (do_sync_read+0x69/0x98) from [<c00759a1>] (vfs_read+0x69/0x11c)
> [<c00759a1>] (vfs_read+0x69/0x11c) from [<c0075acd>] (sys_read+0x2d/0x48)
> [<c0075acd>] (sys_read+0x2d/0x48) from [<c0027c41>] (ret_fast_syscall+0x1/0x40)
> 
> 
> The patch below fixes the problem. Basically, the nfs_readdata_release()
> is called from nfs_direct_read_schedule_segment() before
> data->args.context was initialised, hence the oops. The same happens on
> the nfs_writedata_release() path.

Hi Catalin,

How about the following instead? This patch gets rid of those
nfs_open_context references altogether...

Cheers
  Trond
-----------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Fix an O_DIRECT Oops...

We can't call nfs_readdata_release()/nfs_writedata_release() without
first initialising and referencing args.context. Doing so inside
nfs_direct_read_schedule_segment()/nfs_direct_write_schedule_segment()
causes an Oops.
We should rather be calling nfs_readdata_free()/nfs_writedata_free() in
those cases.

Looking at the O_DIRECT code, the "struct nfs_direct_req" is already
referencing the nfs_open_context for us. Since the readdata and writedata
structures carry a reference to that, we can simplify things by getting rid
of the extra nfs_open_context references, so that we can replace all
instances of nfs_readdata_release()/nfs_writedata_release().

Reported-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c        |   20 ++++++++++----------
 fs/nfs/read.c          |    6 ++----
 fs/nfs/write.c         |    6 ++----
 include/linux/nfs_fs.h |    5 ++---
 4 files changed, 16 insertions(+), 21 deletions(-)


diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 489fc01..e4e089a 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -255,7 +255,7 @@ static void nfs_direct_read_release(void *calldata)
 
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
-	nfs_readdata_release(calldata);
+	nfs_readdata_free(data);
 }
 
 static const struct rpc_call_ops nfs_read_direct_ops = {
@@ -314,14 +314,14 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 					data->npages, 1, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
-			nfs_readdata_release(data);
+			nfs_readdata_free(data);
 			break;
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
 				nfs_direct_release_pages(data->pagevec, result);
-				nfs_readdata_release(data);
+				nfs_readdata_free(data);
 				break;
 			}
 			bytes -= pgbase;
@@ -334,7 +334,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
-		data->args.context = get_nfs_open_context(ctx);
+		data->args.context = ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
@@ -441,7 +441,7 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 		struct nfs_write_data *data = list_entry(dreq->rewrite_list.next, struct nfs_write_data, pages);
 		list_del(&data->pages);
 		nfs_direct_release_pages(data->pagevec, data->npages);
-		nfs_writedata_release(data);
+		nfs_writedata_free(data);
 	}
 }
 
@@ -534,7 +534,7 @@ static void nfs_direct_commit_release(void *calldata)
 
 	dprintk("NFS: %5u commit returned %d\n", data->task.tk_pid, status);
 	nfs_direct_write_complete(dreq, data->inode);
-	nfs_commitdata_release(calldata);
+	nfs_commit_free(data);
 }
 
 static const struct rpc_call_ops nfs_commit_direct_ops = {
@@ -570,7 +570,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->args.fh = NFS_FH(data->inode);
 	data->args.offset = 0;
 	data->args.count = 0;
-	data->args.context = get_nfs_open_context(dreq->ctx);
+	data->args.context = dreq->ctx;
 	data->res.count = 0;
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
@@ -734,14 +734,14 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 					data->npages, 0, 0, data->pagevec, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (result < 0) {
-			nfs_writedata_release(data);
+			nfs_writedata_free(data);
 			break;
 		}
 		if ((unsigned)result < data->npages) {
 			bytes = result * PAGE_SIZE;
 			if (bytes <= pgbase) {
 				nfs_direct_release_pages(data->pagevec, result);
-				nfs_writedata_release(data);
+				nfs_writedata_free(data);
 				break;
 			}
 			bytes -= pgbase;
@@ -756,7 +756,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
 		data->args.fh = NFS_FH(inode);
-		data->args.context = get_nfs_open_context(ctx);
+		data->args.context = ctx;
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 73ea5e8..12c9e66 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -60,17 +60,15 @@ struct nfs_read_data *nfs_readdata_alloc(unsigned int pagecount)
 	return p;
 }
 
-static void nfs_readdata_free(struct nfs_read_data *p)
+void nfs_readdata_free(struct nfs_read_data *p)
 {
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_rdata_mempool);
 }
 
-void nfs_readdata_release(void *data)
+static void nfs_readdata_release(struct nfs_read_data *rdata)
 {
-	struct nfs_read_data *rdata = data;
-
 	put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0a0a2ff..a34fae2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -87,17 +87,15 @@ struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 	return p;
 }
 
-static void nfs_writedata_free(struct nfs_write_data *p)
+void nfs_writedata_free(struct nfs_write_data *p)
 {
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_wdata_mempool);
 }
 
-void nfs_writedata_release(void *data)
+static void nfs_writedata_release(struct nfs_write_data *wdata)
 {
-	struct nfs_write_data *wdata = data;
-
 	put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index fdffb41..f6b9024 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -473,7 +473,6 @@ extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
-extern void nfs_writedata_release(void *);
 
 /*
  * Try to write back everything synchronously (but check the
@@ -488,7 +487,6 @@ extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-extern void nfs_commitdata_release(void *wdata);
 #else
 static inline int
 nfs_commit_inode(struct inode *inode, int how)
@@ -507,6 +505,7 @@ nfs_have_writebacks(struct inode *inode)
  * Allocate nfs_write_data structures
  */
 extern struct nfs_write_data *nfs_writedata_alloc(unsigned int npages);
+extern void nfs_writedata_free(struct nfs_write_data *);
 
 /*
  * linux/fs/nfs/read.c
@@ -515,7 +514,6 @@ extern int  nfs_readpage(struct file *, struct page *);
 extern int  nfs_readpages(struct file *, struct address_space *,
 		struct list_head *, unsigned);
 extern int  nfs_readpage_result(struct rpc_task *, struct nfs_read_data *);
-extern void nfs_readdata_release(void *data);
 extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
 			       struct page *);
 
@@ -523,6 +521,7 @@ extern int  nfs_readpage_async(struct nfs_open_context *, struct inode *,
  * Allocate nfs_read_data structures
  */
 extern struct nfs_read_data *nfs_readdata_alloc(unsigned int npages);
+extern void nfs_readdata_free(struct nfs_read_data *);
 
 /*
  * linux/fs/nfs3proc.c
