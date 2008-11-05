From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/18] NLM: Support IPv6 scope IDs in nlm_display_address()
Date: Wed, 05 Nov 2008 12:19:43 -0500
Message-ID: <20081105171942.6773.78274.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35883 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbYKERUh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:37 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scope ID support is needed since NSM now uses these displayed addresses
as a mon_name in some cases.  Without scope ID support, NSM will fail
to handle peers that contact us via a link-local address (if
nsm_use_hostnames is zero).  Link-local addresses do not work without
an interface ID, which is stored in the sockaddr's sin6_scope_id field.

As a clean up, create a LOCKD_ADDRBUF_SIZE macro to control the size of
the buffers used to store presentation format addresses, and increase the size
of these buffers to accomodate an interface ID for IPv6 addresses with a
non-zero scope ID.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   33 ++++++++++++++++++++++++---------
 include/linux/lockd/lockd.h |   11 ++++++++---
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9fd8889..50b7787 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -104,25 +104,40 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
-static void nlm_display_address(const struct sockaddr *sap,
-				char *buf, const size_t len)
+static void nlm_display_ipv4_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
 {
 	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+}
+
+static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
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
+}
+
+static void nlm_display_address(const struct sockaddr *sap,
+				char *buf, const size_t len)
+{
 	switch (sap->sa_family) {
 	case AF_UNSPEC:
-		snprintf(buf, len, "unspecified");
+		snprintf(buf, len, "unspecified address");
 		break;
 	case AF_INET:
-		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
+		nlm_display_ipv4_address(sap, buf, len);
 		break;
 	case AF_INET6:
-		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			snprintf(buf, len, NIPQUAD_FMT,
-				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
-		else
-			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
+		nlm_display_ipv6_address(sap, buf, len);
 		break;
 	default:
 		snprintf(buf, len, "unsupported address family");
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 830148e..3e0b7a8 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -36,6 +36,11 @@
 #define LOCKD_DFLT_TIMEO	10
 
 /*
+ * Size of presentation format address buffer
+ */
+#define LOCKD_ADDRBUF_SIZE	63
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
+	char			h_addrbuf[LOCKD_ADDRBUF_SIZE],
+				h_srcaddrbuf[LOCKD_ADDRBUF_SIZE];
 };
 
 struct nsm_handle {
@@ -77,7 +82,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
-	char			sm_addrbuf[48];	/* address eyecatcher */
+	char			sm_addrbuf[LOCKD_ADDRBUF_SIZE];
 };
 
 /*

