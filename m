From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] NLM: Support IPv6 scope IDs in nlm_display_address()
Date: Mon, 01 Dec 2008 13:57:42 -0500
Message-ID: <20081201185741.10600.7375.stgit@ingres.1015granger.net>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:40682 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbYLAS7v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:59:51 -0500
In-Reply-To: <20081201185108.10600.21700.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 fs/lockd/host.c             |   31 +++++++++++++++++++++++--------
 include/linux/lockd/lockd.h |    2 +-
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 68e00c0..cd7edc3 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -105,22 +105,37 @@ static void nlm_clear_port(struct sockaddr *sap)
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
index 4467b83..307a8f0 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -75,7 +75,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
-	char			sm_addrbuf[48];	/* address eyecatcher */
+	char			sm_addrbuf[63];	/* presentation address */
 };
 
 /*

