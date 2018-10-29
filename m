Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95159C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:55:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 64885204FD
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:55:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64885204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727834AbeJ3Cos (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:44:48 -0400
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:43992 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726998AbeJ3Cos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Oct 2018 22:44:48 -0400
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3889A80D;
        Mon, 29 Oct 2018 10:55:08 -0700 (PDT)
Received: from e112298-lin.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 901743F6A8;
        Mon, 29 Oct 2018 10:55:06 -0700 (PDT)
From:   Julien Thierry <julien.thierry@arm.com>
To:     linux-nfs@vger.kernel.org
Cc:     Julien Thierry <julien.thierry@arm.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix iter_iov_*vec warnings
Date:   Mon, 29 Oct 2018 17:55:01 +0000
Message-Id: <1540835701-23176-1-git-send-email-julien.thierry@arm.com>
X-Mailer: git-send-email 1.9.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While booting linux-next on Juno with rootfs over NFS, the following
warning is spammed on kernel log:

[   16.988190] WARNING: CPU: 1 PID: 680 at lib/iov_iter.c:1082 iov_iter_kvec+0x20/0x40
[   16.995776] Modules linked in:
[   16.998801] CPU: 1 PID: 680 Comm: kworker/u13:0 Not tainted 4.19.0-next-20181029 #2238
[   17.006640] Hardware name: ARM Juno development board (r0) (DT)
[   17.012505] Workqueue: xprtiod xs_stream_data_receive_workfn
[   17.018108] pstate: 00000005 (nzcv daif -PAN -UAO)
[   17.022851] pc : iov_iter_kvec+0x20/0x40
[   17.026733] lr : xs_stream_data_receive+0x194/0x378
[   17.031559] sp : ffff00000b033ce0
[   17.034836] x29: ffff00000b033ce0 x28: 0000000000000000
[   17.040095] x27: ffff8009760b9870 x26: ffff00000917e1c8
[   17.045352] x25: 0000000000000000 x24: ffff800976a91598
[   17.050610] x23: ffff000009169000 x22: ffff8009775f0000
[   17.055867] x21: 000000000000000c x20: ffff800976a91578
[   17.061124] x19: ffff800976a91000 x18: 0000000000000000
[   17.066381] x17: 0000000000000000 x16: 0000000000000000
[   17.071639] x15: 0000000000000400 x14: 0000000000000400
[   17.076896] x13: 0000000000000400 x12: 0000000000002f28
[   17.082153] x11: 0000000000000000 x10: 0000000000000960
[   17.087410] x9 : ffff00000b033d50 x8 : fefefefefefefeff
[   17.092667] x7 : ffff80097ff9d380 x6 : 0000000000000000
[   17.097924] x5 : 00646f6974727078 x4 : 000000000000000c
[   17.103181] x3 : 0000000000000001 x2 : ffff00000b033d30
[   17.108438] x1 : 0000000000000002 x0 : ffff00000b033d50
[   17.113695] Call trace:
[   17.116115]  iov_iter_kvec+0x20/0x40
[   17.119652]  xs_stream_data_receive_workfn+0x10/0x18
[   17.124568]  process_one_work+0x1c8/0x318
[   17.128535]  worker_thread+0x48/0x428
[   17.132158]  kthread+0xf8/0x128
[   17.135266]  ret_from_fork+0x10/0x18
[   17.138801] ---[ end trace 65cbcd2ddaeef59e ]---

This is likely a clash between the recent addition of vector iterators to
SUNRPC and the recent
commit aa563d7bca6e882ec2bdae24603c8f016401a144 ("iov_iter: Separate
type from direction and use accessor functions") which slightly changes
the usage of those iterators by splitting type and direction.

Fix this by not including type in the direction of the operation.

Fixes: 277e4ab7d530bf287e02b65cfcd3ea8f489784f6 ("SUNRPC: Simplify TCP
receive code by switching to using iterators")

Signed-off-by: Julien Thierry <julien.thierry@arm.com>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1b51e04..ae77c71 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -361,7 +361,7 @@ static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 xs_read_kvec(struct socket *sock, struct msghdr *msg, int flags,
 		struct kvec *kvec, size_t count, size_t seek)
 {
-	iov_iter_kvec(&msg->msg_iter, READ | ITER_KVEC, kvec, 1, count);
+	iov_iter_kvec(&msg->msg_iter, READ, kvec, 1, count);
 	return xs_sock_recvmsg(sock, msg, flags, seek);
 }
 
@@ -370,7 +370,7 @@ static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 		struct bio_vec *bvec, unsigned long nr, size_t count,
 		size_t seek)
 {
-	iov_iter_bvec(&msg->msg_iter, READ | ITER_BVEC, bvec, nr, count);
+	iov_iter_bvec(&msg->msg_iter, READ, bvec, nr, count);
 	return xs_sock_recvmsg(sock, msg, flags, seek);
 }
 
-- 
1.9.1

