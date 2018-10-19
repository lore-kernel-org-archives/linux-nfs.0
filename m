Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:54368 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727315AbeJSWzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 18:55:06 -0400
From: Cristian Marussi <cristian.marussi@arm.com>
Subject: [aarch64] refcount_t: use-after-free in NFS with 64k pages
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: "trond.myklebust@hammerspace.com anna.schumaker"@netapp.com
Message-ID: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
Date: Fri, 19 Oct 2018 15:48:36 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I'm recently chasing a bug that frequently appears during our internal 
LTP test-runs when performed on aarch64 HW (Juno) systems with an 
NFS-mounted root.

The failure is NOT related to any specific LTP testcase and this issue 
has been observed only when Kernel is configured to use 64KB pages.
(on the latest LTP Sept18 TAG test suite a Kernel crash happened in 4 
out of 5 test runs...always on a different random test case)

I'm testing on Linus branch on 4.19-rc6 (but I can see it up to 4.19-rc8 
and also on next) and it is reported since 4.17 at least (not sure about 
this...anyway it was NOT happening)

It all starts with a stacktrace as follows:

[  214.513856] refcount_t: increment on 0; use-after-free.
[  214.519701] WARNING: CPU: 0 PID: 1397 at 
/home//ARM/dev/src/pdsw/linux/lib/refcount.c:153 
refcount_inc_checked+0x40/0x48
[  214.520010] Modules linked in:
[  214.520606] CPU: 0 PID: 1397 Comm: kworker/u2:5 Not tainted 
4.19.0-rc4-00135-g4b92e7fd76e9 #17
[  214.520732] Hardware name: Foundation-v8A (DT)
[  214.521258] Workqueue: writeback wb_workfn (flush-0:17)
[  214.521629] pstate: 40000005 (nZcv daif -PAN -UAO)
[  214.521739] pc : refcount_inc_checked+0x40/0x48
[  214.521826] lr : refcount_inc_checked+0x40/0x48
[  214.521910] sp : ffff00000c3ef850
[  214.521981] x29: ffff00000c3ef850 x28: ffff800841a8bf00
[  214.522172] x27: 000000007fffffff x26: ffff000009173000
[  214.522301] x25: 0000000000000002 x24: ffff00000c3ef960
[  214.522419] x23: ffff8008202484d8 x22: ffff800841a8c580
[  214.522523] x21: ffff00000c3ef950 x20: ffff8008202484d8
[  214.522628] x19: ffff800841a8c580 x18: 0000000000000400
[  214.522744] x17: 0000000000000002 x16: 0000000000000000
[  214.522849] x15: 0000000000000400 x14: 0000000000000400
[  214.522963] x13: 0000000000000003 x12: 0000000000000001
[  214.523063] x11: 0000000000000000 x10: 0000000000000950
[  214.523181] x9 : ffff00000c3ef560 x8 : ffff800840d2f3b0
[  214.523284] x7 : ffff800840d2eac0 x6 : 0000000000004c0e
[  214.523390] x5 : 0000000000004c0e x4 : 0000000000000040
[  214.523512] x3 : 0000800876a30000 x2 : ffff00000918b0b8
[  214.523619] x1 : 114d6487b94add00 x0 : 0000000000000000
[  214.523865] Call trace:
[  214.524034]  refcount_inc_checked+0x40/0x48
[  214.524194]  nfs_scan_commit_list+0x64/0x158
[  214.524300]  nfs_scan_commit.part.12+0x70/0xc8
[  214.524367]  __nfs_commit_inode+0xa8/0x190
[  214.524429]  nfs_io_completion_commit+0x14/0x20
[  214.524495]  nfs_io_completion_put.part.0+0x28/0x40
[  214.524566]  nfs_writepages+0x114/0x1f8
[  214.524656]  do_writepages+0x54/0x100
[  214.524722]  __writeback_single_inode+0x38/0x1b0
[  214.524795]  writeback_sb_inodes+0x1bc/0x3b0
[  214.524860]  wb_writeback+0xe8/0x1e0
[  214.524920]  wb_workfn+0xac/0x2f0
[  214.525011]  process_one_work+0x1e0/0x318
[  214.525079]  worker_thread+0x40/0x450
[  214.525136]  kthread+0x128/0x130
[  214.525200]  ret_from_fork+0x10/0x18
[  214.525378] ---[ end trace 085bda95b972076a ]---
[  214.527357] WARNING: CPU: 0 PID: 2247 at 
/home//ARM/dev/src/pdsw/linux/fs/nfs/pagelist.c:426 
nfs_free_request+0x180/0x188
[  214.527473] Modules linked in:
[  214.527603] CPU: 0 PID: 2247 Comm: kworker/0:10 Tainted: G        W 
       4.19.0-rc4-00135-g4b92e7fd76e9 #17
[  214.527694] Hardware name: Foundation-v8A (DT)
[  214.527836] Workqueue: nfsiod rpc_async_release
[  214.527941] pstate: 00000005 (nzcv daif -PAN -UAO)
[  214.528012] pc : nfs_free_request+0x180/0x188
[  214.528084] lr : nfs_release_request+0x7c/0xa8
[  214.528150] sp : ffff00000a3afc90
[  214.528215] x29: ffff00000a3afc90 x28: 0000000000000000
[  214.528319] x27: 0000000000000000 x26: ffff000008e7ac08
[  214.528439] x25: 0000000000000000 x24: ffff800841169d20
[  214.528543] x23: ffff800841169c50 x22: ffff000009173000
[  214.528663] x21: ffff800841a86ac0 x20: ffff800841a88980
[  214.528765] x19: ffff800841a86ac0 x18: 0000000000000400
[  214.528878] x17: 0000000000000c02 x16: 0000000000000000
[  214.528985] x15: 0000000000000400 x14: 0000000000000400
[  214.529089] x13: 0000000000000001 x12: 0000000000000001
[  214.529210] x11: ffff7fe0021f2080 x10: 0000000000000001
[  214.529336] x9 : 0000000000000230 x8 : 0000000000000001
[  214.529445] x7 : 0000000000000006 x6 : 0000000000000000
[  214.529554] x5 : ffff0000091736c8 x4 : 61c8864680b583eb
[  214.529655] x3 : ffff000009170180 x2 : 114d6487b94add00
[  214.529768] x1 : 0000000000000000 x0 : 0000000000000c02
[  214.529875] Call trace:
[  214.529936]  nfs_free_request+0x180/0x188
[  214.530004]  nfs_release_request+0x7c/0xa8
[  214.530081]  nfs_release_request+0x58/0xa8
[  214.530148]  nfs_write_completion+0x108/0x1d0
[  214.530226]  nfs_pgio_release+0x14/0x20
[  214.530303]  rpc_free_task+0x28/0x48
[  214.530365]  rpc_async_release+0x10/0x18
[  214.530435]  process_one_work+0x1e0/0x318
[  214.530511]  worker_thread+0x40/0x450
[  214.530576]  kthread+0x128/0x130
[  214.530637]  ret_from_fork+0x10/0x18
[  214.530703] ---[ end trace 085bda95b972076b ]---
[  214.561905] 
=============================================================================
[  214.562272] BUG nfs_page (Tainted: G        W        ): Poison 
overwritten
[  214.562380] 
-----------------------------------------------------------------------------
[  214.562380]
[  214.562556] Disabling lock debugging due to kernel taint
[  214.562890] INFO: 0x00000000b97c0237-0x000000008961d49d. First byte 
0x6d instead of 0x6b
[  214.563217] INFO: Slab 0x00000000904824d1 objects=341 used=341 fp=0x 
         (null) flags=0x1fffc00000000100
[  214.563342] INFO: Object 0x0000000027f0bc03 @offset=47872 
fp=0x00000000d28ef0cf
[  214.563342]
[  214.563896] Redzone 00000000bf6d5f5c: bb bb bb bb bb bb bb bb bb bb 
bb bb bb bb bb bb  ................
[  214.564049] Redzone 00000000176bf877: bb bb bb bb bb bb bb bb bb bb 
bb bb bb bb bb bb  ................
[  214.564160] Redzone 0000000021a23f7d: bb bb bb bb bb bb bb bb bb bb 
bb bb bb bb bb bb  ................
[  214.564250] Redzone 00000000867bf55b: bb bb bb bb bb bb bb bb bb bb 
bb bb bb bb bb bb  ................
[  214.564368] Object 0000000027f0bc03: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  214.564470] Object 00000000e1d63013: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  214.564559] Object 0000000048d2aff2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  214.564650] Object 000000009988735f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6d 6b 6b 6b  kkkkkkkkkkkkmkkk
[  214.564749] Object 00000000f2578c10: 6b 7b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b 6b  k{kkkkkkkkkkkkkk
[  214.564837] Object 00000000f5216ea3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  214.564992] Redzone 00000000cfb0e6ed: bb bb bb bb bb bb bb bb 
                  ........
[  214.565105] Padding 00000000ef117243: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 
5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  214.565404] CPU: 0 PID: 2344 Comm: dd Tainted: G    B   W 
4.19.0-rc4-00135-g4b92e7fd76e9 #17
[  214.565507] Hardware name: Foundation-v8A (DT)
[  214.565676] Call trace:

So after the refcount warn, there are other warns about wb_flags 
consistency and finally (if enabled) a Poison Overwritten is detected on 
the nfs_page. In other runs with slub_debug disabled it can finally hit 
various invalid dereference request or the BUG() inside 
nfs_unlock_request().

Observing that this deadly sequence usually derives from a file sync 
event or an exiting process(a terminating test case) closing and 
flushing files to NFS, I tried to reproduce it quicker using a script 
which spawns a number of dd processes, killing randomly some of them, 
and periodically syncing in background.
Such script when run on a ARM FastModel aarch64 (which by itself is 
slower than HW and monothreaded) is able to reproduce the same above 
issue 100% of time within 30 secs if using properly sized dd writes 
(~160KB). (but ONLY on 64KB pages Kernel)

Ftracing and annotating NFS code I tracked down the usage of such 
nfs_pages and I made the following observations:

- a number of nfs_page objects which are apparently still actively used 
by NFS (and so still linked to some NFS list via wb_list) got freed 
because the refcount wb_kref drops to zero. (such rogue nfs_pages are 
also linked between themselves in a single flock)

- earlier during the same test run these same nfs_page objects can be 
observed to have been previously properly linked/unlinked and freed (so 
I think we can exclude the issue is tied to a specific nfs_page object 
instance and specific underlying physical location)

- wb_list handling NFS wrapper functions nfs_list_add_request() and 
nfs_list_remove_request() seems to be handling properly items addition 
and removal: I could NOT find a call to nfs_list_add_request() issued on 
an element not previously cleanly initialized or unlinked with 
nfs_list_remove_request()

- when the crash happens nicely enough, you can see these rogue pages 
being still properly manipulated (unlinked !) by NFS code after the 
freeing (and the warnings)..it's just too late.

For this reasons now I think it is the refcount which is wrongly 
accounted in this particular situation, and it drops to zero 
prematurely; I don't think anymore that this crash is due to some stale 
nfs_page not having been properly unlinked or being reachable from a 
stale dangling pointer.

As a proof of concept, if I track down when the evil is going to happen 
(freeing a still wb_list-linked nfs_page...) and I artificially pump up 
by one the wb_kref refcount just before (so delaying the free)...the 
issue disappears...without any memory leak (given what kmemleak and 
slub_debug says)

So applying this patch below (which is NOT meant to be a fix but just a 
workaround to validate all of the above) the issue goes completely away 
and I could run my 30secs-failing test case for ~12 hours. On real HW I 
could now run successfully 10/10 full LTP test runs in a row without any 
issue too.

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index bb5476a6d264..171813f9a291 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -432,6 +432,15 @@ void nfs_free_request(struct nfs_page *req)

  void nfs_release_request(struct nfs_page *req)
  {
+       /* WORKAROUND */
+       if ((kref_read(&req->wb_kref) == 1) &&
+           (req->wb_list.prev != &req->wb_list ||
+            req->wb_list.next != &req->wb_list)) {
+               pr_warn("%s -- Forcing REFCOUNT++ on dirty req[%u]:%px 
->prev:%px  ->next:%px\n",
+                       __func__, kref_read(&req->wb_kref), req,
+                       req->wb_list.prev, req->wb_list.next);
+               kref_get(&req->wb_kref);
+       }
         kref_put(&req->wb_kref, nfs_page_group_destroy);
  }
  EXPORT_SYMBOL_GPL(nfs_release_request);

I still have to figure out WHY this is happening when the system is 
loaded AND only with 64kb pages. (so basically the root cause...:<)

What I could see is that the refcount bad-accounting seems to originate 
during the early phase of nfs_page allocation:

- OK: nfs_create_request creates straight away an nfs_page wb_kref +2

- OK: nfs_create_request creates a nfs_page with wb_kref +1 AND then 
wb_kref is immediately after incremented to +2 by an 
nfs_inode_add_request() before being moved across wb_list

- FAIL: nfs_create_request creates a nfs_page with wb_kref +1 and it 
remains to +1 till when it starts being moved across lists.

Any ideas or suggestions to triage why this condition is happening ?
(I'm not really an NFS guy...:D)

Thanks

Cristian
