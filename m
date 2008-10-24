From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/14] NLM: Beef up NLM address display function
Date: Fri, 24 Oct 2008 14:09:54 -0400
Message-ID: <20081024180954.23810.34150.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14121 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbYJXSLR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:17 -0400
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m9OIBEUj008178
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:14 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id m9OIBDVk002770
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:13 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OI9sk0023881
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:09:54 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for IPv6 addresses with a scope ID, and enable calls from
outside of fs/lockd/host.c

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   51 ++++++++++++++++++++++++++++++++-----------
 include/linux/lockd/lockd.h |   13 ++++++++---
 2 files changed, 48 insertions(+), 16 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9fd8889..c7516ae 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -104,29 +104,54 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
-static void nlm_display_address(const struct sockaddr *sap,
-				char *buf, const size_t len)
+static int nlm_display_ipv4_address(const struct sockaddr *sap, char *buf,
+				    const size_t len)
 {
 	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+
+	return 0;
+}
+
+static int nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
+				    const size_t len)
+{
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
+	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
+		snprintf(buf, len, NIPQUAD_FMT,
+				NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
+	else if (sin6->sin6_scope_id != 0)
+		snprintf(buf, len, NIP6_FMT "%%%u", NIP6(sin6->sin6_addr),
+				sin6->sin6_scope_id);
+	else
+		snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
+
+	return 0;
+}
+
+/**
+ * nlm_display_address - Convert sockaddr to presentation format
+ * @sap: pointer to socket address
+ * @buf: pointer to buffer to fill in
+ * @len: length of buffer
+ *
+ */
+int nlm_display_address(const struct sockaddr *sap, char *buf,
+			const size_t len)
+{
 	switch (sap->sa_family) {
 	case AF_UNSPEC:
-		snprintf(buf, len, "unspecified");
-		break;
+		snprintf(buf, len, "unspecified address");
+		return -EAFNOSUPPORT;
 	case AF_INET:
-		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-		break;
+		return nlm_display_ipv4_address(sap, buf, len);
 	case AF_INET6:
-		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			snprintf(buf, len, NIPQUAD_FMT,
-				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
-		else
-			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
-		break;
+		return nlm_display_ipv6_address(sap, buf, len);
 	default:
 		snprintf(buf, len, "unsupported address family");
-		break;
+		return -EAFNOSUPPORT;
 	}
 }
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b56d5aa..4e713f9 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -36,6 +36,11 @@
 #define LOCKD_DFLT_TIMEO	10
 
 /*
+ * Size of presentation format address buffer
+ */
+#define LOCKD_ADDRBUF		55
+
+/*
  * Lockd host handle (used both by the client and server personality).
  */
 struct nlm_host {
@@ -65,8 +70,8 @@ struct nlm_host {
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
 
-	char			h_addrbuf[48],	/* address eyecatchers */
-				h_srcaddrbuf[48];
+	char			h_addrbuf[LOCKD_ADDRBUF],
+				h_srcaddrbuf[LOCKD_ADDRBUF];
 };
 
 struct nsm_handle {
@@ -77,7 +82,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
-	char			sm_addrbuf[48];	/* address eyecatcher */
+	char			sm_addrbuf[LOCKD_ADDRBUF];
 };
 
 /*
@@ -224,6 +229,8 @@ struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
 struct nlm_host  *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 					const char *hostname,
 					const size_t hostname_len);
+int		  nlm_display_address(const struct sockaddr *sap,
+					char *buf, const size_t len);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);

