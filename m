Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4156 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbGMSCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:02:05 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 03/10] SUNRPC: Drop double-underscores from rpc_cmp_addr{4|6}()
Date: Mon, 13 Jul 2015 14:01:26 -0400
Message-ID: <1436810493-22806-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm planning on using these functions inside the client, so remove the
underscores to make it feel like I'm using a public interface.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 include/linux/sunrpc/addr.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
index 07d8e53..772faef 100644
--- a/include/linux/sunrpc/addr.h
+++ b/include/linux/sunrpc/addr.h
@@ -46,8 +46,8 @@ static inline void rpc_set_port(struct sockaddr *sap,
 #define IPV6_SCOPE_DELIMITER		'%'
 #define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
 
-static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
+static inline bool rpc_cmp_addr4(const struct sockaddr *sap1,
+				 const struct sockaddr *sap2)
 {
 	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
 	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
@@ -67,8 +67,8 @@ static inline bool __rpc_copy_addr4(struct sockaddr *dst,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
+static inline bool rpc_cmp_addr6(const struct sockaddr *sap1,
+				 const struct sockaddr *sap2)
 {
 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
@@ -122,9 +122,9 @@ static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
 	if (sap1->sa_family == sap2->sa_family) {
 		switch (sap1->sa_family) {
 		case AF_INET:
-			return __rpc_cmp_addr4(sap1, sap2);
+			return rpc_cmp_addr4(sap1, sap2);
 		case AF_INET6:
-			return __rpc_cmp_addr6(sap1, sap2);
+			return rpc_cmp_addr6(sap1, sap2);
 		}
 	}
 	return false;
-- 
2.4.5

