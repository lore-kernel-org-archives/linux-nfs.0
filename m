From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/17] NLM: Support IPv6 scope IDs in nlm_display_address()
Date: Thu, 04 Dec 2008 14:20:08 -0500
Message-ID: <20081204192008.8039.81626.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:49545 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbYLDTU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:26 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scope ID support is needed since the kernel's NSM implementation is
about to use these displayed addresses as a mon_name in some cases.

If nsm_use_hostnames is zero, NSM will fail to handle peers that
contact us via a link-local address without scope ID support.  Link-
local addresses do not work without an interface ID, which is stored
in the sockaddr's sin6_scope_id field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   24 ++++++++++++++++--------
 include/linux/lockd/lockd.h |   10 +++++++++-
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 359e1aa..eddb176 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -105,22 +105,30 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
-static void nlm_display_address(const struct sockaddr *sap,
-				char *buf, const size_t len)
+static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
 {
-	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
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
 	case AF_INET:
 		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
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
index dae22cb..80a0a2c 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -68,6 +68,14 @@ struct nlm_host {
 	char			*h_addrbuf;	/* address eyecatcher */
 };
 
+/*
+ * The largest string sm_addrbuf should hold is a full-size IPv6 address
+ * (no "::" anywhere) with a scope ID.  The buffer size is computed to
+ * hold eight groups of colon-separated four-hex-digit numbers, a
+ * percent sign, a scope id (at most 32 bits, in decimal), and NUL.
+ */
+#define NSM_ADDRBUF		((8 * 4 + 7) + (1 + 10) + 1)
+
 struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
@@ -76,7 +84,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
-	char			sm_addrbuf[48];	/* address eyecatcher */
+	char			sm_addrbuf[NSM_ADDRBUF];
 };
 
 /*

