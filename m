From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/14] mount command: Add functions to manage addresses in
	string form
Date: Fri, 11 Jul 2008 16:34:29 -0400
Message-ID: <20080711203429.478.13881.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39499 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136AbYGKUfc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:32 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce two new functions to convert a sockaddr to a presentation format
string and back.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   92 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    4 ++
 2 files changed, 96 insertions(+), 0 deletions(-)


diff --git a/utils/mount/network.c b/utils/mount/network.c
index c9fd548..3f2721b 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -215,6 +215,98 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *sin)
 					(struct sockaddr *)sin, &len);
 }
 
+/**
+ * nfs_string_to_sockaddr - convert string address to sockaddr
+ * @address:	pointer to presentation format address to convert
+ * @addrlen:	length of presentation address
+ * @sap:	pointer to socket address buffer to fill in
+ * @salen:	IN: length of address buffer
+ *		OUT: length of converted socket address
+ *
+ * Convert a presentation format address string to a socket address.
+ * Similar to nfs_name_to_address(), but the DNS query is squelched,
+ * and won't make any noise if the getaddrinfo() call fails.
+ *
+ * Returns 1 and fills in @sap and @salen if successful; otherwise zero.
+ *
+ * See RFC 4038 section 5.1 or RFC 3513 section 2.2 for more details
+ * on presenting IPv6 addresses as text strings.
+ */
+int nfs_string_to_sockaddr(const char *address, const size_t addrlen,
+			   struct sockaddr *sap, socklen_t *salen)
+{
+	struct addrinfo *gai_results;
+	struct addrinfo gai_hint = {
+		.ai_flags	= AI_NUMERICHOST,
+	};
+	socklen_t len = *salen;
+	int ret = 0;
+
+	*salen = 0;
+
+	if (getaddrinfo(address, NULL, &gai_hint, &gai_results) == 0) {
+		switch (gai_results->ai_addr->sa_family) {
+		case AF_INET:
+		case AF_INET6:
+			if (len >= gai_results->ai_addrlen) {
+				*salen = gai_results->ai_addrlen;
+				memcpy(sap, gai_results->ai_addr, *salen);
+				ret = 1;
+			}
+			break;
+		}
+		freeaddrinfo(gai_results);
+	}
+
+	return ret;
+}
+
+/**
+ * nfs_present_sockaddr - convert sockaddr to string
+ * @sap: pointer to socket address to convert
+ * @salen: length of socket address
+ * @buf: pointer to buffer to fill in
+ * @buflen: length of buffer
+ *
+ * Convert the passed-in sockaddr-style address to presentation format.
+ * The presentation format address is placed in @buf and is
+ * '\0'-terminated.
+ *
+ * Returns 1 if successful; otherwise zero.
+ *
+ * See RFC 4038 section 5.1 or RFC 3513 section 2.2 for more details
+ * on presenting IPv6 addresses as text strings.
+ */
+int nfs_present_sockaddr(const struct sockaddr *sap, const socklen_t salen,
+			 char *buf, const size_t buflen)
+{
+#ifdef HAVE_GETNAMEINFO
+	int result;
+
+	result = getnameinfo(sap, salen, buf, buflen,
+					NULL, 0, NI_NUMERICHOST);
+	if (!result)
+		return 1;
+
+	nfs_error(_("%s: invalid server address: %s"), progname,
+			gai_strerror(result));
+	return 0;
+#else	/* HAVE_GETNAMEINFO */
+	char *addr;
+
+	if (sap->sa_family == AF_INET) {
+		addr = inet_ntoa(((struct sockaddr_in *)sap)->sin_addr);
+		if (addr && strlen(addr) < buflen) {
+			strcpy(buf, addr);
+			return 1;
+		}
+	}
+
+	nfs_error(_("%s: invalid server address"), progname);
+	return 0;
+#endif	/* HAVE_GETNAMEINFO */
+}
+
 /*
  * Attempt to connect a socket, but time out after "timeout" seconds.
  *
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 9de13b5..8da7e20 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -53,6 +53,10 @@ int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_name_to_address(const char *, const sa_family_t,
 		struct sockaddr *, socklen_t *);
+int nfs_string_to_sockaddr(const char *, const size_t,
+			   struct sockaddr *, socklen_t *);
+int nfs_present_sockaddr(const struct sockaddr *,
+			 const socklen_t, char *, const size_t);
 int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,

