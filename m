Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:47350 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932904AbcKQKfs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 05:35:48 -0500
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        stable@vger.kernel.org, Daniel Wagner <daniel.wagner@bmw-carit.de>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 4.8 51/92] xprtrdma: use complete() instead complete_all()
Date: Thu, 17 Nov 2016 11:32:24 +0100
Message-Id: <20161117103226.356879238@linuxfoundation.org>
In-Reply-To: <20161117103224.218007793@linuxfoundation.org>
References: <20161117103224.218007793@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

4.8-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

commit 5690a22d8612e1788b48b4ea53c59868589cd2db upstream.

There is only one waiter for the completion, therefore there
is no need to use complete_all(). Let's make that clear by
using complete() instead of complete_all().

The usage pattern of the completion is:

waiter context                          waker context

frwr_op_unmap_sync()
  reinit_completion()
  ib_post_send()
  wait_for_completion()

					frwr_wc_localinv_wake()
					  complete()

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -329,7 +329,7 @@ frwr_wc_localinv_wake(struct ib_cq *cq,
 	frmr = container_of(cqe, struct rpcrdma_frmr, fr_cqe);
 	if (wc->status != IB_WC_SUCCESS)
 		__frwr_sendcompletion_flush(wc, frmr, "localinv");
-	complete_all(&frmr->fr_linv_done);
+	complete(&frmr->fr_linv_done);
 }
 
 /* Post a REG_MR Work Request to register a memory region


