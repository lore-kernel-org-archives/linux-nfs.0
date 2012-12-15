Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:35177 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700Ab2LOWck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 Dec 2012 17:32:40 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Handle ECONNREFUSED in xs_local_setup_socket
Date: Sat, 15 Dec 2012 17:32:34 -0500
Message-Id: <1355610755-27787-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355610755-27787-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1355610755-27787-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Silence the unnecessary warning "unhandled error (111) connecting to..."
and convert it to a dprintk for debugging purposes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprtsock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6db26e5..7163ef5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1902,6 +1902,10 @@ static void xs_local_setup_socket(struct work_struct *work)
 		dprintk("RPC:       xprt %p: socket %s does not exist\n",
 				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
 		break;
+	case -ECONNREFUSED:
+		dprintk("RPC:       xprt %p: connection refused for %s\n",
+				xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
+		break;
 	default:
 		printk(KERN_ERR "%s: unhandled error (%d) connecting to %s\n",
 				__func__, -status,
-- 
1.7.11.7

