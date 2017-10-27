Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:56892 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdJ0QoU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 12:44:20 -0400
Subject: [PATCH 4/4] xprtrdma: Update copyright notices
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Oct 2017 12:44:18 -0400
Message-ID: <20171027164418.10826.90620.stgit@manet.1015granger.net>
In-Reply-To: <20171027164014.10826.10151.stgit@manet.1015granger.net>
References: <20171027164014.10826.10151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Credit work contributed by Oracle engineers since 2014.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/rpc_rdma.h |    1 +
 net/sunrpc/xprtrdma/rpc_rdma.c  |    1 +
 net/sunrpc/xprtrdma/transport.c |    1 +
 net/sunrpc/xprtrdma/verbs.c     |    1 +
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 5 files changed, 5 insertions(+)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 840afac..8f144db 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2015-2017 Oracle. All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 45cb549..ed34dc0 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2014-2017 Oracle.  All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index dcc2df0..04494bb 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2014-2017 Oracle.  All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index be61c29..710b3f7 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2014-2017 Oracle.  All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 8b9954c..51686d9 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -1,4 +1,5 @@
 /*
+ * Copyright (c) 2014-2017 Oracle.  All rights reserved.
  * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two

