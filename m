Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33680 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbdF2NZh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jun 2017 09:25:37 -0400
Received: by mail-qt0-f193.google.com with SMTP id c20so11236681qte.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Jun 2017 06:25:37 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 29 Jun 2017 09:25:36 -0400
Message-ID: <CAN-5tyEX1Z_3EB3h6=z_S1E=gpTObOrcP5Ub2HmVKBB5RaU1DQ@mail.gmail.com>
Subject: [RFC] fix parallelism for rpc tasks
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

On a multi-core machine, is it expected that we can have parallel RPCs
handled by each of the per-core workqueue?

In testing a read workload, observing via "top" command that a single
"kworker" thread is running servicing the requests (no parallelism).
It's more prominent while doing these operations over krb5p mount.

What has been suggested by Bruce is to try this and in my testing I
see then the read workload spread among all the kworker threads.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 0cc8383..f80e688 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1095,7 +1095,7 @@ static int rpciod_start(void)
  * Create the rpciod thread and wait for it to start.
  */
  dprintk("RPC:       creating workqueue rpciod\n");
- wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
+ wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
  if (!wq)
  goto out_failed;
  rpciod_workqueue = wq;
