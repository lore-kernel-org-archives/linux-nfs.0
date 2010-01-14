From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/24] statd: Add API to canonicalize mon_names
Date: Thu, 14 Jan 2010 12:31:28 -0500
Message-ID: <20100114173128.26079.56076.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:37190 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757373Ab0ANRcM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:32:12 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a shared function to generate canonical names that statd
uses to index its on-disk monitor list.  This function can resolve
DNS hostnames, and IPv4 and IPv6 presentation addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |  101 ++++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/statd.h    |    2 +
 2 files changed, 103 insertions(+), 0 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 7571b6f..7d704cc 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -39,6 +39,10 @@
 #include "statd.h"
 #include "xlog.h"
 
+#ifndef HAVE_DECL_AI_ADDRCONFIG
+#define AI_ADDRCONFIG	0
+#endif
+
 /**
  * statd_present_address - convert sockaddr to presentation address
  * @sap: pointer to socket address to convert
@@ -126,6 +130,103 @@ get_addrinfo(const char *hostname, const struct addrinfo *hint)
 	return NULL;
 }
 
+#ifdef HAVE_GETNAMEINFO
+static _Bool
+get_nameinfo(const struct sockaddr *sap, const socklen_t salen,
+		/*@out@*/ char *buf, const socklen_t buflen)
+{
+	int error;
+
+	error = getnameinfo(sap, salen, buf, buflen, NULL, 0, NI_NAMEREQD);
+	if (error != 0) {
+		xlog(D_GENERAL, "%s: failed to resolve address: %s",
+				__func__, gai_strerror(error));
+		return false;
+	}
+
+	return true;
+}
+#else	/* !HAVE_GETNAMEINFO */
+static _Bool
+get_nameinfo(const struct sockaddr *sap,
+		__attribute__ ((unused)) const socklen_t salen,
+		/*@out@*/ char *buf, socklen_t buflen)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)(char *)sap;
+	struct hostent *hp;
+
+	if (sin->sin_family != AF_INET) {
+		xlog(D_GENERAL, "%s: unknown address family: %d",
+				sin->sin_family);
+		return false;
+	}
+
+	hp = gethostbyaddr((const char *)&(sin->sin_addr.s_addr),
+				sizeof(struct in_addr), AF_INET);
+	if (hp == NULL) {
+		xlog(D_GENERAL, "%s: failed to resolve address: %m", __func__);
+		return false;
+	}
+
+	strncpy(buf, hp->h_name, (size_t)buflen);
+	return true;
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
+/**
+ * statd_canonical_name - choose file name for monitor record files
+ * @hostname: C string containing hostname or presentation address
+ *
+ * Returns a '\0'-terminated ASCII string containing a fully qualified
+ * canonical hostname, or NULL if @hostname does not have a reverse
+ * mapping.  Caller must free the result with free(3).
+ *
+ * Incoming hostnames are looked up to determine the canonical hostname,
+ * and incoming presentation addresses are converted to canonical
+ * hostnames.
+ *
+ * We won't monitor peers that don't have a reverse map.  The canonical
+ * name gives us a key for our monitor list.
+ */
+__attribute_malloc__
+char *
+statd_canonical_name(const char *hostname)
+{
+	struct addrinfo hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
+		.ai_flags	= AI_NUMERICHOST,
+		.ai_protocol	= (int)IPPROTO_UDP,
+	};
+	char buf[NI_MAXHOST];
+	struct addrinfo *ai;
+
+	ai = get_addrinfo(hostname, &hint);
+	if (ai != NULL) {
+		/* @hostname was a presentation address */
+		_Bool result;
+		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
+					buf, (socklen_t)sizeof(buf));
+		freeaddrinfo(ai);
+		if (!result)
+			return NULL;
+		return strdup(buf);
+	}
+
+	/* @hostname was a hostname */
+	hint.ai_flags = AI_CANONNAME;
+	ai = get_addrinfo(hostname, &hint);
+	if (ai == NULL)
+		return NULL;
+	strcpy(buf, ai->ai_canonname);
+	freeaddrinfo(ai);
+
+	return strdup(buf);
+}
+
 /**
  * statd_matchhostname - check if two hostnames are equivalent
  * @hostname1: C string containing hostname
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index c2d5956..e89e666 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -25,6 +25,8 @@
 extern _Bool	statd_matchhostname(const char *hostname1, const char *hostname2);
 extern _Bool	statd_present_address(const struct sockaddr *sap, char *buf,
 					const size_t buflen);
+__attribute_malloc__
+extern char *	statd_canonical_name(const char *hostname);
 
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);

