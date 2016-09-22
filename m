Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atlantic540.startdedicated.de ([188.138.9.77]:43960 "EHLO
        atlantic540.startdedicated.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754140AbcIVLy6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 07:54:58 -0400
From: Daniel Wagner <wagi@monom.org>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org,
        Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: [PATCH 1/2] NFS: direct: use complete() instead of complete_all()
Date: Thu, 22 Sep 2016 13:54:28 +0200
Message-Id: <1474545269-8694-2-git-send-email-wagi@monom.org>
In-Reply-To: <1474545269-8694-1-git-send-email-wagi@monom.org>
References: <1474545269-8694-1-git-send-email-wagi@monom.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

There is only one waiter for the completion, therefore there
is no need to use complete_all(). Let's make that clear by
using complete() instead of complete_all().

nfs_file_direct_write() or nfs_file_direct_read() allocated a request
object via nfs_direct_req_alloc(), which initializes the
completion. The request object then is freed later in the exit path.
Between the initialization and the release either
nfs_direct_write_schedule_iovec() resp
nfs_direct_read_schedule_iovec() are called which will asynchronously
process the request. The calling function waits via nfs_direct_wait()
till the async work has been done. Thus there is only one waiter on
the completion.

nfs_direct_pgio_init() and nfs_direct_read_completion() are passed via
function pointers to nfs pageio. The first function does a ref
counting (get_dreq() and put_dreq()) which ensures that
nfs_direct_read_completion() and nfs_direct_read_schedule_iovec() only
call the completion path once.

The usage pattern of the completion is:

waiter context                          waker context

nfs_file_direct_write()
  dreq = nfs_direct_req_alloc()
    init_completion()
  nfs_direct_write_schedule_iovec()
  nfs_direct_wait()
    wait_for_completion_killable()

                                        nfs_direct_write_schedule_work()
                                          nfs_direct_complete()
                                            complete()

nfs_file_direct_read()
  dreq = nfs_direct_req_all()
    init_completion()
  nfs_direct_read_schedule_iovec()
  nfs_direct_wait()
    wait_for_completion_killable()
                                        nfs_direct_read_schedule_iovec()
                                          nfs_direct_complete()
                                            complete()

                                        nfs_direct_read_completion()
                                          nfs_direct_complete()
                                            complete()

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
---
 fs/nfs/direct.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 72b7d13..bd81bcf 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -387,7 +387,7 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 		dreq->iocb->ki_complete(dreq->iocb, res, 0);
 	}
 
-	complete_all(&dreq->completion);
+	complete(&dreq->completion);
 
 	nfs_direct_req_release(dreq);
 }
-- 
2.7.4
