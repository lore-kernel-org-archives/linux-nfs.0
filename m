Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46899 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757026AbcBXR4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:23 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] NFS add multiaddr mount option
Date: Wed, 24 Feb 2016 12:55:59 -0500
Message-ID: <1456336559-17334-3-git-send-email-andros@netapp.com>
In-Reply-To: <1456336559-17334-1-git-send-email-andros@netapp.com>
References: <1456336559-17334-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/mount/stropts.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 75646f6..041bbcd 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -365,6 +365,60 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	return 1;
 }
 
+/**
+ * Returns 1 if multiaddr= opttion appended successfully
+ * otherwise zero
+ */
+static int
+nfs_append_multiaddr_option(char *multinames, struct mount_options *options,
+				int family)
+{
+	struct addrinfo hint = {
+		.ai_protocol    = (int)IPPROTO_UDP,
+		.ai_family = family,
+	};
+	char *comma, *name;
+	struct addrinfo *temp;
+	int error, failed = 1;
+
+	if (!multinames)
+		return 0;
+
+	name = multinames;
+	comma = strchr(name, ',');
+	while (name != NULL) {
+		if (comma != NULL)
+			*comma = '\0';
+
+		error = getaddrinfo(name, NULL, &hint, &temp);	
+		if (error != 0) {
+			nfs_error(_("%s: Failed to resolve server %s: %s"),
+				progname, name, gai_strerror(error));
+			continue;
+		}
+
+		if (!nfs_append_generic_address_option(temp->ai_addr,
+							temp->ai_addrlen,
+							"multiaddr", options)) {
+			nfs_error(_("%s: Failed to append multiaddr %s"),
+				progname, name);
+			continue;
+		}
+		failed = 0;
+		if (comma == NULL)
+			name = NULL;
+		else {
+			name = comma +1;
+			comma = strchr(name, ',');
+		}
+	}
+
+	if (failed == 1)
+		return 0;
+	else
+		return 1;
+}
+
 /*
  * Set up mandatory non-version specific NFS mount options.
  *
@@ -403,6 +457,11 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 					mi->address->ai_addrlen, mi->options))
 		return 0;
 
+	if ((mi->version.major == 4 && mi->version.minor > 0))
+		if (!nfs_append_multiaddr_option(mi->multinames, mi->options,
+						family))
+			return 0;
+
 	return 1;
 }
 
-- 
1.8.3.1

