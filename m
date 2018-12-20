Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E69F1C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:35:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB8F22186A
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 15:35:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730512AbeLTPfL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 10:35:11 -0500
Received: from fieldses.org ([173.255.197.46]:48524 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729211AbeLTPfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 10:35:11 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 6FCEE2C0; Thu, 20 Dec 2018 10:35:11 -0500 (EST)
Date:   Thu, 20 Dec 2018 10:35:11 -0500
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: handle ENOMEM in rpcb_getport_async
Message-ID: <20181220153511.GB6063@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

If we ignore the error we'll hit a null dereference a little later.

Reported-by: syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/rpcb_clnt.c | 8 ++++++++
 1 file changed, 8 insertions(+)

Looks like this is still a bug?

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index c7872bc13860..08b5fa4a2852 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -771,6 +771,12 @@ void rpcb_getport_async(struct rpc_task *task)
 	case RPCBVERS_3:
 		map->r_netid = xprt->address_strings[RPC_DISPLAY_NETID];
 		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_ATOMIC);
+		if (!map->r_addr) {
+			status = -ENOMEM;
+			dprintk("RPC: %5u %s: no memory available\n",
+				task->tk_pid, __func__);
+			goto bailout_free_args;
+		}
 		map->r_owner = "";
 		break;
 	case RPCBVERS_2:
@@ -793,6 +799,8 @@ void rpcb_getport_async(struct rpc_task *task)
 	rpc_put_task(child);
 	return;
 
+bailout_free_args:
+	kfree(map);
 bailout_release_client:
 	rpc_release_client(rpcb_clnt);
 bailout_nofree:
-- 
2.19.2

