Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:31374 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab2LDMSi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:18:38 -0500
Subject: [PATCH] SUNRPC: remove redundant "linux/nsproxy.h" includes
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 15:18:58 +0300
Message-ID: <20121204121856.3029.355.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/rpcb_clnt.c |    1 -
 net/sunrpc/svc.c       |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a70acae..109a67a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -23,7 +23,6 @@
 #include <linux/errno.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
-#include <linux/nsproxy.h>
 #include <net/ipv6.h>
 
 #include <linux/sunrpc/clnt.h>
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index be301e1..529400d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,7 +20,6 @@
 #include <linux/module.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
-#include <linux/nsproxy.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>

