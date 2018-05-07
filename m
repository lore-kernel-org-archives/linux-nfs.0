Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35365 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752601AbeEGT05 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:26:57 -0400
Subject: [PATCH v1 01/19] svcrdma: Add proper SPDX tags for
 NetApp-contributed source
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:26:55 -0400
Message-ID: <20180507192655.4608.26260.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma.c           |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
 5 files changed, 5 insertions(+)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 7337e12..88da0c9 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
 /*
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index dd8a431..a490532 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 /*
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 3d45015..9eae95d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 /*
  * Copyright (c) 2016, 2017 Oracle. All rights reserved.
  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 649441d..79bd3a3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 /*
  * Copyright (c) 2016 Oracle. All rights reserved.
  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 96cc8f6..3633254 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 /*
  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
  * Copyright (c) 2005-2007 Network Appliance, Inc. All rights reserved.

