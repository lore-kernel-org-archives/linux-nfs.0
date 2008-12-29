From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NLM: Support IPv6 scope IDs in nlm_display_address()
Date: Mon, 29 Dec 2008 17:20:23 -0500
Message-ID: <20081229222023.28005.27171.stgit@ingres.1015granger.net>
References: <20081229221603.28005.42498.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43317 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbYL2WVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Dec 2008 17:21:22 -0500
In-Reply-To: <20081229221603.28005.42498.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scope ID support is needed since the kernel's NSM implementation is
about to use these displayed addresses as a mon_name in some cases.

When nsm_use_hostnames is zero, without scope ID support NSM will fail
to handle peers that contact us via a link-local address.  Link-local
addresses do not work without an interface ID, which is stored in the
sockaddr's sin6_scope_id field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   21 +++++++++++++++------
 include/linux/lockd/lockd.h |   10 +++++++++-
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index beb5da8..012e49a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -105,22 +105,31 @@ static void nlm_clear_port(struct sockaddr *sap)
 	}
 }
 
+static void nlm_display_ipv6_address(const struct sockaddr *sap, char *buf,
+				     const size_t len)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
+		snprintf(buf, len, "%pI4", &sin6->sin6_addr.s6_addr32[3]);
+	else if (sin6->sin6_scope_id != 0)
+		snprintf(buf, len, "%pI6%%%u", &sin6->sin6_addr,
+				sin6->sin6_scope_id);
+	else
+		snprintf(buf, len, "%pI6", &sin6->sin6_addr);
+}
+
 static void nlm_display_address(const struct sockaddr *sap,
 				char *buf, const size_t len)
 {
 	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
 	switch (sap->sa_family) {
 	case AF_INET:
 		snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
 		break;
 	case AF_INET6:
-		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-			snprintf(buf, len, "%pI4",
-				 &sin6->sin6_addr.s6_addr32[3]);
-		else
-			snprintf(buf, len, "%pI6", &sin6->sin6_addr);
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

