From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] nfs-utils: make private cookie to hex conversion a library routine
Date: Fri,  8 Jan 2010 09:56:00 -0500
Message-ID: <1262962563-5554-2-git-send-email-jlayton@redhat.com>
References: <1262962563-5554-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56399 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab0AHO4I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 09:56:08 -0500
In-Reply-To: <1262962563-5554-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nsm.h |    2 ++
 support/nsm/file.c    |   44 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/support/include/nsm.h b/support/include/nsm.h
index 850c191..db53eb2 100644
--- a/support/include/nsm.h
+++ b/support/include/nsm.h
@@ -71,6 +71,8 @@ extern void	nsm_delete_monitored_host(const char *hostname,
 			const char *mon_name, const char *my_name);
 extern void	nsm_delete_notified_host(const char *hostname,
 			const char *mon_name, const char *my_name);
+extern size_t	nsm_priv_to_hex(const char *priv, char *buf,
+				const size_t buflen);
 
 /* rpc.c */
 
diff --git a/support/nsm/file.c b/support/nsm/file.c
index 635fb4e..7e923ef 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -677,6 +677,33 @@ nsm_retire_monitored_hosts(void)
 }
 
 /*
+ * nsm_priv_to_hex - convert a NSM private cookie to a hex string.
+ *
+ * @priv: buffer holding the binary NSM private cookie
+ * @buf: output buffer for NULL terminated hex string
+ * @buflen: size of output buffer
+ *
+ * Returns the length of the resulting string or 0 on error
+ */
+size_t
+nsm_priv_to_hex(const char *priv, char *buf, const size_t buflen)
+{
+	int i, len;
+	size_t remaining = buflen;
+
+	for (i = 0; i < SM_PRIV_SIZE; i++) {
+		len = snprintf(buf, remaining, "%02x",
+				(unsigned int)(0xff & priv[i]));
+		if (error_check(len, remaining))
+			return 0;
+		buf += len;
+		remaining -= (size_t)len;
+	}
+
+	return buflen - remaining;
+}
+
+/*
  * Returns the length in bytes of the created record.
  */
 __attribute_noinline__
@@ -685,8 +712,8 @@ nsm_create_monitor_record(char *buf, const size_t buflen,
 		const struct sockaddr *sap, const struct mon *m)
 {
 	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
-	size_t remaining = buflen;
-	int i, len;
+	size_t hexlen, remaining = buflen;
+	int len;
 
 	len = snprintf(buf, remaining, "%08x %08x %08x %08x ",
 			(unsigned int)sin->sin_addr.s_addr,
@@ -698,14 +725,11 @@ nsm_create_monitor_record(char *buf, const size_t buflen,
 	buf += len;
 	remaining -= (size_t)len;
 
-	for (i = 0; i < SM_PRIV_SIZE; i++) {
-		len = snprintf(buf, remaining, "%02x",
-				(unsigned int)(0xff & m->priv[i]));
-		if (error_check(len, remaining))
-			return 0;
-		buf += len;
-		remaining -= (size_t)len;
-	}
+	hexlen = nsm_priv_to_hex(m->priv, buf, remaining);
+	if (hexlen == 0)
+		return 0;
+	buf += hexlen;
+	remaining -= hexlen;
 
 	len = snprintf(buf, remaining, " %s %s\n",
 			m->mon_id.mon_name, m->mon_id.my_id.my_name);
-- 
1.6.5.2

