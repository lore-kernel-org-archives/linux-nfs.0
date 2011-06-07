Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52386 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab1FGRfD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:03 -0400
Date: Tue, 7 Jun 2011 13:35:01 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 77/88] move include lines out of include file
Message-ID: <756f1079ab4fab5692f021ee6a48cef26931f791.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
[This patch does *not* break the header's independence]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/simple_rpc_pipefs.h |    6 ------
 net/sunrpc/simple_rpc_pipefs.c           |    5 ++---
 2 files changed, 2 insertions(+), 9 deletions(-)

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
index c9306aa..24af0a1 100644
--- a/net/sunrpc/simple_rpc_pipefs.c
+++ b/net/sunrpc/simple_rpc_pipefs.c
@@ -38,9 +38,8 @@
  *  With thanks to CITI's project sponsor and partner, IBM.
  */
 
-#include <linux/completion.h>
-#include <linux/uaccess.h>
-#include <linux/module.h>
+#include <linux/mount.h>
+#include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/simple_rpc_pipefs.h>
 
 
-- 
1.7.4.1

