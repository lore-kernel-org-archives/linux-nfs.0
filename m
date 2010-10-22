Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:58753 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab0JVAvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 20:51:24 -0400
Date: Thu, 21 Oct 2010 20:51:20 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] move include lines out of include file
Message-ID: <20101022005120.GA15788@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 include/linux/sunrpc/simple_rpc_pipefs.h |    6 ------
 net/sunrpc/simple_rpc_pipefs.c           |    5 +++++
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/simple_rpc_pipefs.h b/include/linux/sunrpc/simple_rpc_pipefs.h
index 02e8147..f6a1227 100644
--- a/include/linux/sunrpc/simple_rpc_pipefs.h
+++ b/include/linux/sunrpc/simple_rpc_pipefs.h
@@ -39,14 +39,8 @@
 #ifndef _SIMPLE_RPC_PIPEFS_H_
 #define _SIMPLE_RPC_PIPEFS_H_
 
-#include <linux/fs.h>
-#include <linux/list.h>
-#include <linux/mount.h>
-#include <linux/sched.h>
-#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 
-
 #define payload_of(headerp)  ((void *)(headerp + 1))
 
 /*
diff --git a/net/sunrpc/simple_rpc_pipefs.c b/net/sunrpc/simple_rpc_pipefs.c
index c9306aa..b749cf7 100644
--- a/net/sunrpc/simple_rpc_pipefs.c
+++ b/net/sunrpc/simple_rpc_pipefs.c
@@ -41,6 +41,11 @@
 #include <linux/completion.h>
 #include <linux/uaccess.h>
 #include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/list.h>
+#include <linux/mount.h>
+#include <linux/sched.h>
+#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/simple_rpc_pipefs.h>
 
 
-- 
1.7.0.4

