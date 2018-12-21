Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2561C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:35:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C9E4821917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:35:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732977AbeLURf1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:35:27 -0500
Received: from relay.sw.ru ([185.231.240.75]:40888 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730364AbeLURf1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:35:27 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOho-0004ut-MH; Fri, 21 Dec 2018 20:35:24 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 3/8] sunrpc: introduce per-netns
 sunrpc_net->bc_prep_reply_hdr()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <457b3440-bcbb-2af4-65e7-8af75ef7be32@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:35:23 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545412216.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently svc_process_common() uses quite complex schema to adjust reply
header, only required for tcp transports.
This patch adds an alternative way to access required function:
function pointer is added into per-netns sunrpc_net structure during
creation of back channel svc_xprt.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/netns.h    | 2 ++
 net/sunrpc/svc_xprt.c | 5 +++++
 net/sunrpc/svcsock.c  | 3 +++
 3 files changed, 10 insertions(+)

diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index 7ec10b92bea1..ff067107e4f7 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -6,6 +6,7 @@
 #include <net/netns/generic.h>
 
 struct cache_detail;
+struct svc_rqst;
 
 struct sunrpc_net {
 	struct proc_dir_entry *proc_net_rpc;
@@ -33,6 +34,7 @@ struct sunrpc_net {
 	int pipe_version;
 	atomic_t pipe_users;
 	struct proc_dir_entry *use_gssp_proc;
+	void (*bc_prep_reply_hdr)(struct svc_rqst *);
 };
 
 extern unsigned int sunrpc_net_id;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 51d36230b6e3..2ffeecfa0978 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -19,6 +19,8 @@
 #include <linux/netdevice.h>
 #include <trace/events/sunrpc.h>
 
+#include "netns.h"
+
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
 static unsigned int svc_rpc_per_connection_limit __read_mostly;
@@ -134,8 +136,11 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+	struct sunrpc_net *sn = net_generic(xprt->xpt_net, sunrpc_net_id);
+
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
+	sn->bc_prep_reply_hdr = NULL;
 	put_net(xprt->xpt_net);
 	/* See comment on corresponding get in xs_setup_bc_tcp(): */
 	if (xprt->xpt_bc_xprt)
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 986f3ed7d1a2..7c0f9439f94c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -55,6 +55,7 @@
 #include <linux/sunrpc/xprt.h>
 
 #include "sunrpc.h"
+#include "netns.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -1608,6 +1609,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 {
 	struct svc_sock *svsk;
 	struct svc_xprt *xprt;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	if (protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only TCP sockets"
@@ -1623,6 +1625,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 
+	sn->bc_prep_reply_hdr = svc_tcp_prep_reply_hdr;
 	serv->sv_bc_xprt = xprt;
 
 	return xprt;
-- 
2.17.1

