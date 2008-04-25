From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 12:20:19 -0400
Message-ID: <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com>
References: <20080425080535.GA4999@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-1-1052468929
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26087 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757327AbYDYQVM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 12:21:12 -0400
In-Reply-To: <20080425080535.GA4999-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail-1-1052468929
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

On Apr 25, 2008, at 4:05 AM, Steinar H. Gunderson wrote:
> (Via a user bug report)
>
> It seems retry= is now additive with the text-based mount interface.  
> In
> particular, "mount -o retry=0" still gives a two-minute timeout. Is  
> this
> intentional?


No, it's broken.  Can you test the attached patch?


--Apple-Mail-1-1052468929
Content-Disposition: attachment;
	filename=fix-retry-option
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="fix-retry-option"
Content-Transfer-Encoding: 7bit

text-based mount command: Fix retry= option

Steinar Gunderson reports:

"It seems retry= is now additive with the text-based mount interface. In
particular, "mount -o retry=0" still gives a two-minute timeout."

Make retry option parsing more robust, while we're at it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   55 ++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 43 insertions(+), 12 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cadb1f4..4df9ad9 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -65,6 +65,14 @@
 #define NFS_MAXPATHNAME		(1024)
 #endif
 
+#ifndef NFS_DEF_FG_TIMEOUT_MINUTES
+#define NFS_DEF_FG_TIMEOUT_MINUTES	(2ul)
+#endif
+
+#ifndef NFS_DEF_BG_TIMEOUT_MINUTES
+#define NFS_DEF_BG_TIMEOUT_MINUTES	(10000ul)
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -141,6 +149,35 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 }
 
 /*
+ * Set up a timeout value based on the value of the "retry=" option.
+ *
+ * Returns 1 if the option was parsed successfully, otherwise zero.
+ * Returns the parsed timeout, or the default, in *timeout.
+ */
+static int parse_retry_option(time_t *timeout, struct mount_options *options,
+			      unsigned long timeout_minutes)
+{
+	char *retry_option, *endptr;
+
+	retry_option = po_get(options, "retry");
+	if (retry_option) {
+		long tmp;
+
+		errno = 0;
+		tmp = strtol(retry_option, &endptr, 10);
+		if (errno || endptr == retry_option || tmp < 0) {
+			nfs_error(_("%s: incorrect retry timeout specified"),
+					progname);
+			return 0;
+		}
+		timeout_minutes = tmp;
+	}
+
+	*timeout += time(NULL) + (time_t)(timeout_minutes * 60);
+	return 1;
+}
+
+/*
  * Append the 'addr=' option to the options string to pass a resolved
  * server address to the kernel.  After a successful mount, this address
  * is also added to /etc/mtab for use when unmounting.
@@ -535,13 +572,10 @@ static int nfsmount_fg(const char *spec, const char *node,
 		       char **extra_opts)
 {
 	unsigned int secs = 1;
-	time_t timeout = time(NULL);
-	char *retry;
+	time_t timeout;
 
-	timeout += 60 * 2;		/* default: 2 minutes */
-	retry = po_get(options, "retry");
-	if (retry)
-		timeout += 60 * atoi(retry);
+	if (!parse_retry_option(&timeout, options, NFS_DEF_FG_TIMEOUT_MINUTES))
+		return EX_FAIL;
 
 	if (verbose)
 		printf(_("%s: timeout set for %s"),
@@ -612,13 +646,10 @@ static int nfsmount_child(const char *spec, const char *node,
 			  int fake, char **extra_opts)
 {
 	unsigned int secs = 1;
-	time_t timeout = time(NULL);
-	char *retry;
+	time_t timeout;
 
-	timeout += 60 * 10000;		/* default: 10,000 minutes */
-	retry = po_get(options, "retry");
-	if (retry)
-		timeout += 60 * atoi(retry);
+	if (!parse_retry_option(&timeout, options, NFS_DEF_BG_TIMEOUT_MINUTES))
+		return EX_FAIL;
 
 	for (;;) {
 		if (sleep(secs))

--Apple-Mail-1-1052468929
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7bit



--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
--Apple-Mail-1-1052468929--
