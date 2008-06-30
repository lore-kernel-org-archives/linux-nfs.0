From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] mount: Introduce IPv6-aware DNS resolver API function
Date: Mon, 30 Jun 2008 13:10:36 -0400
Message-ID: <20080630171035.9905.87279.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29734 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYF3RLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:11:06 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new DNS resolver function in utils/mount/network.c that uses
getaddrinfo(3), which supports AF_INET6, to resolve host names.

Replace the guts of nfs_gethostbyname() with a call to the new function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   78 +++++++++++++++++++++++++++++++++++++------------
 utils/mount/network.h |    2 +
 2 files changed, 61 insertions(+), 19 deletions(-)


diff --git a/utils/mount/network.c b/utils/mount/network.c
index ab7f6d0..30a4d40 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -144,32 +144,72 @@ static const unsigned long probe_mnt3_first[] = {
 };
 
 /**
+ * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
+ * @hostname: pointer to C string containing DNS hostname to resolve
+ * @sap: pointer to buffer to fill with socket address
+ * @len: IN: size of buffer to fill; OUT: size of socket address
+ *
+ * Returns 1 and places a socket address at @sap if successful;
+ * otherwise zero.
+ */
+int nfs_name_to_address(const char *hostname,
+			const sa_family_t af_hint,
+			struct sockaddr *sap, socklen_t *salen)
+{
+	struct addrinfo *gai_results;
+	struct addrinfo gai_hint = {
+		.ai_family	= af_hint,
+		.ai_flags	= AI_ADDRCONFIG,
+	};
+	socklen_t len = *salen;
+	int error, ret = 0;
+
+	if (af_hint == AF_INET6)
+		gai_hint.ai_flags |= AI_V4MAPPED|AI_ALL;
+
+	*salen = 0;
+
+	error = getaddrinfo(hostname, NULL, &gai_hint, &gai_results);
+	if (error) {
+		nfs_error(_("%s: DNS resolution failed for %s: %s"),
+			progname, hostname, (error == EAI_SYSTEM ?
+				strerror(errno) : gai_strerror(error)));
+		return ret;
+	}
+
+	switch (gai_results->ai_addr->sa_family) {
+	case AF_INET:
+	case AF_INET6:
+		if (len >= gai_results->ai_addrlen) {
+			*salen = gai_results->ai_addrlen;
+			memcpy(sap, gai_results->ai_addr, *salen);
+			ret = 1;
+		}
+		break;
+	default:
+		/* things are really broken if we get here, so warn */
+		nfs_error(_("%s: unrecognized DNS resolution results for %s"),
+				progname, hostname);
+		break;
+	}
+
+	freeaddrinfo(gai_results);
+	return ret;
+}
+
+/**
  * nfs_gethostbyname - resolve a hostname to an IPv4 address
  * @hostname: pointer to a C string containing a DNS hostname
  * @saddr: returns an IPv4 address 
  *
  * Returns 1 if successful, otherwise zero.
  */
-int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
+int nfs_gethostbyname(const char *hostname, struct sockaddr_in *sin)
 {
-	struct hostent *hp;
-
-	saddr->sin_family = AF_INET;
-	if (!inet_aton(hostname, &saddr->sin_addr)) {
-		if ((hp = gethostbyname(hostname)) == NULL) {
-			nfs_error(_("%s: can't get address for %s\n"),
-					progname, hostname);
-			return 0;
-		} else {
-			if (hp->h_length > sizeof(*saddr)) {
-				nfs_error(_("%s: got bad hp->h_length\n"),
-						progname);
-				hp->h_length = sizeof(*saddr);
-			}
-			memcpy(&saddr->sin_addr, hp->h_addr, hp->h_length);
-		}
-	}
-	return 1;
+	socklen_t len = sizeof(*sin);
+
+	return nfs_name_to_address(hostname, AF_INET,
+					(struct sockaddr *)sin, &len);
 }
 
 /*
diff --git a/utils/mount/network.h b/utils/mount/network.h
index e0a5dd5..9de13b5 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -51,6 +51,8 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int nfs_name_to_address(const char *, const sa_family_t,
+		struct sockaddr *, socklen_t *);
 int get_client_address(struct sockaddr_in *, struct sockaddr_in *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,

