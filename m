From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/14] text-based mount command: Add helper to construct
	network addresses
Date: Fri, 11 Jul 2008 16:34:40 -0400
Message-ID: <20080711203440.478.97385.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39601 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993AbYGKUfu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:50 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are three helpers that convert sockaddr-style addresses to text
addresses, then construct mount options to pass these addresses to the
kernel.  The tail of each of these helpers does exactly the same thing,
so introduce a helper that handles the common code.

Magically, the new helper supports IPv6 as well as IPv4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a9c0b50..a1ffca2 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -195,6 +195,37 @@ static time_t nfs_parse_retry_option(struct mount_options *options,
 }
 
 /*
+ * Convert the passed-in sockaddr-style address to presentation
+ * format, then append an option of the form "keyword=address".
+ *
+ * Returns 1 if the option was appended successfully; otherwise zero.
+ */
+static int nfs_append_generic_address_option(const struct sockaddr *sap,
+					     const socklen_t salen,
+					     const char *keyword,
+					     struct mount_options *options)
+{
+	char address[NI_MAXHOST];
+	char new_option[512];
+
+	if (!nfs_present_sockaddr(sap, salen, address, sizeof(address)))
+		goto out_err;
+
+	if (snprintf(new_option, sizeof(new_option), "%s=%s",
+					keyword, address) >= sizeof(new_option))
+		goto out_err;
+
+	if (po_append(options, new_option) != PO_SUCCEEDED)
+		goto out_err;
+
+	return 1;
+
+out_err:
+	nfs_error(_("%s: failed to construct %s option"), progname, keyword);
+	return 0;
+}
+
+/*
  * Append the 'addr=' option to the options string to pass a resolved
  * server address to the kernel.  After a successful mount, this address
  * is also added to /etc/mtab for use when unmounting.

