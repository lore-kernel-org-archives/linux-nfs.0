Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:38288 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897AbcD0PhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:37:11 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 2/2] NFS add multiaddr mount option
Date: Wed, 27 Apr 2016 11:36:47 -0400
Message-ID: <1461771407-16423-3-git-send-email-andros@netapp.com>
In-Reply-To: <1461771407-16423-1-git-send-email-andros@netapp.com>
References: <1461771407-16423-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/mount/stropts.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 75646f6..334638b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -365,6 +365,59 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	return 1;
 }
 
+/**
+ * Append any multiaddrs to the mount options to be used for session trunking.
+ *
+ * Do not fail the mount due to multiaddr processing.
+ *
+ * @multinames: comma separated multi-host list. NOTE: does not include the
+ *		first host name which is used as the mount host.
+ */
+static void
+nfs_append_multiaddr_option(char *multinames, struct mount_options *options,
+				int family)
+{
+	struct addrinfo hint = {
+		.ai_protocol    = (int)IPPROTO_UDP,
+		.ai_family = family,
+	};
+	char *comma, *name;
+	struct addrinfo *temp;
+	int error;
+
+	if (!multinames)
+		return;
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
+		if (comma == NULL)
+			name = NULL;
+		else {
+			name = comma +1;
+			comma = strchr(name, ',');
+		}
+	}
+	return;
+}
+
 /*
  * Set up mandatory non-version specific NFS mount options.
  *
@@ -403,6 +456,13 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 					mi->address->ai_addrlen, mi->options))
 		return 0;
 
+	if ((mi->version.major == 4 && mi->version.minor > 0))
+		nfs_append_multiaddr_option(mi->multinames, mi->options,
+					    family);
+	else
+		if (mi->multinames)
+			nfs_error(_("%s: warning: multiple hostnames not"
+				    " supported"),progname); 
 	return 1;
 }
 
-- 
1.8.3.1

