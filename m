Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15172C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 16:06:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBB372147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 16:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CbonteKF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726575AbfCLQGp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 12:06:45 -0400
Received: from mail-yw1-f68.google.com ([209.85.161.68]:41929 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726498AbfCLQGp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 12:06:45 -0400
Received: by mail-yw1-f68.google.com with SMTP id q128so2519848ywg.8
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 09:06:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=f+AduVHqAPwSkMqmQVvIhsuAsL7aAXAlFc/D41Uta7w=;
        b=CbonteKFt/LZt6JQ80yHmG3sYUTH1gmkXz70jAFNZ9gkkKy7uHS/ARRwSNAyfyOA2A
         pLmlhVTuos4MHop6TijLpqDDBL0+KFVwy/MLxvwtjMMwBKi/c3U7ifW+uvvZ1ZS1eLKJ
         kymkI8Bvcy8CKnIjT0t1KgXIMKWSvH/yTlsx5LTIBoAabs3dR5lvT4MLgfXRIAx390SG
         VTiJ9jWfAfpRhRCiljiLfkCVi7Nxq0LZ6snP/WpCAxwhv68/wgBucqegAj3ekW1WaIns
         R4mq1mhAJkBICfGDWTev6gFnVgLaEoz08GXbju8HMUUUSv/+lM1PEedvRfCUYC3TsxMt
         EWzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=f+AduVHqAPwSkMqmQVvIhsuAsL7aAXAlFc/D41Uta7w=;
        b=VDA+exzwRwujrU6qHo5o3tuljO58slJ8mmMFopmyRurOBSUVMTvBYGOovZ4W/hXezU
         oPw2F3XYGgR2Yj0VSaSWkn4hcrkT/pIKTyvsMxmeKVByym8pbccBX59uXpL3xuoXrbaO
         YSNFZIvUrR8Gj/qwOOq8RdUJd0JOiqRXjM1tZnVwaFBKxnOizhBgJ8VKqAZtrxy4xDTn
         1xTqVPGcJG/uE/HwGO1bXOQQxc2+4WvY5JfPdO/zQEor8wCoYebtF5nRmEMxSZWukiP8
         92itw+aES7ZW+Fcd5eGkZWDMH0M/FtSZp8qFbui54Y779D62Cwsr963EZniSSK46qEEU
         P/Fw==
X-Gm-Message-State: APjAAAWUNIgmSa/NsIotA7jSXCBIVjSPJXTO/mtBpIG4MLir75dp/bMb
        a+AydnkVPl6Mcdj5PScxdaq73bB0
X-Google-Smtp-Source: APXvYqy9fRnKcUrwi5SXPce3TtX1yRfj90RI4qjzbPb1jBD3hLgpGtsPDRujbTRZADc5IUHf4bNN1g==
X-Received: by 2002:a81:110d:: with SMTP id 13mr31237786ywr.343.1552406803929;
        Tue, 12 Mar 2019 09:06:43 -0700 (PDT)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id 207sm3543494yws.38.2019.03.12.09.06.41
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Mar 2019 09:06:42 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] [SUNRPC] fix null pointer deref in tracepoints in back  channel
Date:   Tue, 12 Mar 2019 12:06:35 -0400
Message-Id: <20190312160635.7323-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Backchannel doesn't have the rq_task->tk_clientid pointer set.

Otherwise can lead to the following oops:
ocalhost login: [  111.385319] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
[  111.388073] #PF error: [normal kernel read fault]
[  111.389452] PGD 80000000290d8067 P4D 80000000290d8067 PUD 75f25067 PMD 0
[  111.391224] Oops: 0000 [#1] SMP PTI
[  111.392151] CPU: 0 PID: 3533 Comm: NFSv4 callback Not tainted 5.0.0-rc7+ #1
[  111.393787] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  111.396340] RIP: 0010:trace_event_raw_event_xprt_enq_xmit+0x6f/0xf0 [sunrpc]
[  111.397974] Code: 00 00 00 48 89 ee 48 89 e7 e8 bd 0a 85 d7 48 85 c0 74 4a 41 0f b7 94 24 e0 00 00 00 48 89 e7 89 50 08 49 8b 94 24 a8 00 00 00 <8b> 52 04 89 50 0c 49 8b 94 24 c0 00 00 00 8b 92 a8 00 00 00 0f ca
[  111.402215] RSP: 0018:ffffb98743263cf8 EFLAGS: 00010286
[  111.403406] RAX: ffffa0890fc3bc88 RBX: 0000000000000003 RCX: 0000000000000000
[  111.405057] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffb98743263cf8
[  111.406656] RBP: ffffa0896f5368f0 R08: 0000000000000246 R09: 0000000000000000
[  111.408437] R10: ffffe19b01c01500 R11: 0000000000000000 R12: ffffa08977d28a00
[  111.410210] R13: 0000000000000004 R14: ffffa089315303f0 R15: ffffa08931530000
[  111.411856] FS:  0000000000000000(0000) GS:ffffa0897bc00000(0000) knlGS:0000000000000000
[  111.413699] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  111.415068] CR2: 0000000000000004 CR3: 000000002ac90004 CR4: 00000000001606f0
[  111.416745] Call Trace:
[  111.417339]  xprt_request_enqueue_transmit+0x2b6/0x4a0 [sunrpc]
[  111.418709]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
[  111.419957]  call_bc_transmit+0xd5/0x170 [sunrpc]
[  111.421067]  __rpc_execute+0x7e/0x3f0 [sunrpc]
[  111.422177]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
[  111.423212]  bc_svc_process+0x281/0x340 [sunrpc]
[  111.424325]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
[  111.425430]  ? remove_wait_queue+0x60/0x60
[  111.426398]  kthread+0xf5/0x130
[  111.427155]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
[  111.428388]  ? kthread_bind+0x10/0x10
[  111.429270]  ret_from_fork+0x1f/0x30

localhost login: [  467.462259] BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
[  467.464411] #PF error: [normal kernel read fault]
[  467.465445] PGD 80000000728c1067 P4D 80000000728c1067 PUD 728c0067 PMD 0
[  467.466980] Oops: 0000 [#1] SMP PTI
[  467.467759] CPU: 0 PID: 3517 Comm: NFSv4 callback Not tainted 5.0.0-rc7+ #1
[  467.469393] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  467.471840] RIP: 0010:trace_event_raw_event_xprt_transmit+0x7c/0xf0 [sunrpc]
[  467.473392] Code: f6 48 85 c0 74 4b 49 8b 94 24 98 00 00 00 48 89 e7 0f b7 92 e0 00 00 00 89 50 08 49 8b 94 24 98 00 00 00 48 8b 92 a8 00 00 00 <8b> 52 04 89 50 0c 41 8b 94 24 a8 00 00 00 0f ca 89 50 10 41 8b 94
[  467.477605] RSP: 0018:ffffabe7434fbcd0 EFLAGS: 00010282
[  467.478793] RAX: ffff99720fc3bce0 RBX: 0000000000000003 RCX: 0000000000000000
[  467.480409] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffabe7434fbcd0
[  467.482011] RBP: ffff99726f631948 R08: 0000000000000246 R09: 0000000000000000
[  467.483591] R10: 0000000070000000 R11: 0000000000000000 R12: ffff997277dfcc00
[  467.485226] R13: 0000000000000000 R14: 0000000000000000 R15: ffff99722fecdca8
[  467.486830] FS:  0000000000000000(0000) GS:ffff99727bc00000(0000) knlGS:0000000000000000
[  467.488596] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  467.489931] CR2: 0000000000000004 CR3: 00000000270e6006 CR4: 00000000001606f0
[  467.491559] Call Trace:
[  467.492128]  xprt_transmit+0x303/0x3f0 [sunrpc]
[  467.493143]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
[  467.494328]  call_bc_transmit+0x49/0x170 [sunrpc]
[  467.495379]  __rpc_execute+0x7e/0x3f0 [sunrpc]
[  467.496451]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
[  467.497467]  bc_svc_process+0x281/0x340 [sunrpc]
[  467.498507]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
[  467.499751]  ? remove_wait_queue+0x60/0x60
[  467.500686]  kthread+0xf5/0x130
[  467.501438]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
[  467.502640]  ? kthread_bind+0x10/0x10
[  467.503454]  ret_from_fork+0x1f/0x30

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/trace/events/sunrpc.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 8451f30..7e899e6 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -712,7 +712,8 @@
 
 	TP_fast_assign(
 		__entry->task_id = rqst->rq_task->tk_pid;
-		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->client_id = rqst->rq_task->tk_client ?
+			rqst->rq_task->tk_client->cl_clid : -1;
 		__entry->xid = be32_to_cpu(rqst->rq_xid);
 		__entry->seqno = rqst->rq_seqno;
 		__entry->status = status;
@@ -742,7 +743,8 @@
 
 	TP_fast_assign(
 		__entry->task_id = task->tk_pid;
-		__entry->client_id = task->tk_client->cl_clid;
+		__entry->client_id = task->tk_client ?
+			task->tk_client->cl_clid : -1;
 		__entry->xid = be32_to_cpu(task->tk_rqstp->rq_xid);
 		__entry->seqno = task->tk_rqstp->rq_seqno;
 		__entry->stage = stage;
-- 
1.8.3.1

