From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/17] mount: Introduce IPv6-aware DNS resolver API function
Date: Mon, 18 Feb 2008 13:36:32 -0500
Message-ID: <20080218183632.19060.46729.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:56886 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbYBRSge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:34 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIaXb9019441
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:34 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIaWGK019378
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support mounting IPv6 servers, introduce a function in network.c that
can resolve hostnames to either IPv4 or IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac          |    2 +
 utils/mount/network.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/network.h |    1 +
 3 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3e600b4..4372fbe 100644
--- a/configure.ac
+++ b/configure.ac
@@ -298,6 +298,8 @@ have_bindresvport6=none
 if test "$enable_ipv6" = yes; then
     AC_CHECK_FUNC(bindresvport6, [have_bindresvport6=lib])
     AC_CHECK_FUNC(inet_ntop, , , AC_MSG_ERROR(Function 'inet_ntop' not found.))
+    AC_CHECK_FUNC(getaddrinfo, , ,
+                AC_MSG_ERROR(Function 'getaddrinfo' not found.))
 fi
 AM_CONDITIONAL(CONFIG_BRP6, [test "$have_bindresvport6" = "none"])
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 6c29e7c..2ffaf49 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -175,6 +175,76 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 	return 1;
 }
 
+/**
+ * nfs_name_to_address - convert hostname to an IPv4 or IPv6 socket address
+ * @hostname: pointer to C string containing DNS hostname to resolve
+ * @hint: which address family to prioritize in the results
+ * @sap: pointer to buffer to fill with result
+ *
+ * Returns zero if successful, or -1 if an error occurred.
+ *
+ * Assumes the sap argument points to a large enough buffer.
+ */
+#ifdef IPV6_SUPPORTED
+int nfs_name_to_address(const char *hostname, const sa_family_t hint,
+			struct sockaddr *sap)
+{
+	struct addrinfo *result, *results;
+	int error;
+
+	error = getaddrinfo(hostname, NULL, NULL, &results);
+	if (error) {
+		gai_strerror(error);
+		goto out_err;
+	}
+	if (!results) {
+		nfs_error(_("%s: no results from getaddrinfo\n"), progname);
+		goto out_err;
+	}
+
+	/*
+	 * Try to find a result whose family matches "hint".  If there
+	 * isn't one, just return the address in the first item.  If
+	 * the caller sets "hint" to AF_UNSPEC, it will never match any
+	 * of the results, and the first one will be returned by default.
+	 */
+	for (result = results; result; result = result->ai_next)
+		if (result->ai_family == hint)
+			break;
+	if (!result)
+		result = results;
+
+	switch (result->ai_family) {
+	case AF_INET:
+		memcpy(sap, result->ai_addr, sizeof(struct sockaddr_in));
+		break;
+	case AF_INET6:
+		memcpy(sap, result->ai_addr, sizeof(struct sockaddr_in6));
+		break;
+	default:
+		nfs_error(_("%s: unrecognized address family: %u\n"),
+			  ((struct sockaddr *)result->ai_addr)->sa_family);
+		error = EAFNOSUPPORT;
+	}
+
+	freeaddrinfo(results);
+
+	if (!error)
+		return 0;
+
+out_err:
+	nfs_error(_("%s: hostname resolution failed for %s\n"),
+			progname, hostname);
+	return -1;
+}
+#else
+int nfs_name_to_address(const char *hostname, const sa_family_t hint,
+			struct sockaddr *sap)
+{
+	return nfs_gethostbyname(hostname, (struct sockaddr_in *)sap);
+}
+#endif
+
 static int __nfs_gs_err_done(const int error)
 {
 	rpc_createerr.cf_stat = RPC_SYSTEMERROR;
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 7cabb16..97538b6 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -48,6 +48,7 @@ static const struct timeval RETRY_TIMEOUT = { 3, 0 };
 
 int probe_bothports(clnt_addr_t *, clnt_addr_t *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
+int nfs_name_to_address(const char *, const sa_family_t, struct sockaddr *);
 int nfs_client_address(const struct sockaddr *, struct sockaddr *, socklen_t *);
 int nfs_call_umount(clnt_addr_t *, dirpath *);
 int clnt_ping(struct sockaddr_in *, const unsigned long,

