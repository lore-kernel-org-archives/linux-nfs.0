From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 3/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:42:28 -0400
Message-ID: <4A7B2414.602@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A7B2324.9090406@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 3d08862cfebb9fb8a360d362bb9e5e761e6b1fb5
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 15:53:36 2009 -0400

    Make Section names case-insensitive which should
    help in locating them resulting in make the config
    files a bit less error prone
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 5f491eb..a8b8037 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -116,6 +116,18 @@ conf_hash(char *s)
 }
 
 /*
+ * Convert letter from upper case to lower case
+ */
+static inline void upper2lower(char *str)
+{
+	char *ptr = str;
+
+	while (*ptr) 
+		*ptr++ = tolower(*ptr);
+}
+
+
+/*
  * Insert a tag-value combination from LINE (the equal sign is at POS)
  */
 static int
@@ -654,6 +666,9 @@ conf_set(int transaction, char *section, char *tag,
 		xlog_warn("conf_set: strdup(\"%s\") failed", section);
 		goto fail;
 	}
+	/* Make Section names case-insensitive */
+	upper2lower(node->section);
+
 	node->tag = strdup(tag);
 	if (!node->tag) {
 		xlog_warn("conf_set: strdup(\"%s\") failed", tag);
