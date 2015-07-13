Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:12344 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbbGMSIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:08:30 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 04/10] SUNRPC: Add an rpc_cmp_addr_port() function
Date: Mon, 13 Jul 2015 14:01:27 -0400
Message-ID: <1436810493-22806-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is to help determine if two sockaddrs are really the same
socket.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/addr.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
index 772faef..9bc3538 100644
--- a/include/linux/sunrpc/addr.h
+++ b/include/linux/sunrpc/addr.h
@@ -131,6 +131,19 @@ static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
 }
 
 /**
+ * rpc_cmp_addr_port - compare the address and port number of two sockaddrs.
+ * @sap1: first sockaddr
+ * @sap2: second sockaddr
+ */
+static inline bool rpc_cmp_addr_port(const struct sockaddr *sap1,
+				     const struct sockaddr *sap2)
+{
+	if (!rpc_cmp_addr(sap1, sap2))
+		return false;
+	return rpc_get_port(sap1) == rpc_get_port(sap2);
+}
+
+/**
  * rpc_copy_addr - copy the address portion of one sockaddr to another
  * @dst: destination sockaddr
  * @src: source sockaddr
-- 
2.4.5

