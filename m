From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 3/9] Ensure configuration values are stored in lower case
Date: Mon, 09 Mar 2009 16:52:04 -0400
Message-ID: <49B58174.3070300@RedHat.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 3b192f9d86e13ee0413c4dcc88229e6bc35cb5c9
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 13:57:10 2009 -0400

    Store values in lower case. This makes it easier to do string
    comparisons when reading lists from the configuration file.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 1b8d098..a362700 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -114,7 +114,16 @@ conf_hash(char *s)
 	}
 	return hash;
 }
+/*
+ * Convert letter from upper case to lower case
+ */
+static inline upper2lower(char *str)
+{
+	char *ptr = str;
 
+	while (*ptr) 
+		*ptr++ = tolower(*ptr);
+}
 /*
  * Insert a tag-value combination from LINE (the equal sign is at POS)
  */
@@ -523,7 +532,7 @@ conf_get_tag_list (char *section)
 	for (; cb; cb = LIST_NEXT(cb, link)) {
 		if (strcasecmp (section, cb->section) == 0) {
 			list->cnt++;
-			node = calloc (1, sizeof *node);
+			node = calloc(1, sizeof *node);
 			if (!node)
 				goto cleanup;
 			node->field = strdup(cb->tag);
@@ -615,7 +624,7 @@ conf_free_list(struct conf_list *list)
 }
 
 int
-conf_begin (void)
+conf_begin(void)
 {
   static int seq = 0;
 
@@ -623,7 +632,7 @@ conf_begin (void)
 }
 
 static struct conf_trans *
-conf_trans_node (int transaction, enum conf_op op)
+conf_trans_node(int transaction, enum conf_op op)
 {
 	struct conf_trans *node;
 
@@ -639,9 +648,9 @@ conf_trans_node (int transaction, enum conf_op op)
 	return node;
 }
 
-/* Queue a set operation.  */
+/* Queue a set operation.  Store value in lower case */
 int
-conf_set (int transaction, char *section, char *tag, 
+conf_set(int transaction, char *section, char *tag, 
 	char *value, int override, int is_default)
 {
 	struct conf_trans *node;
@@ -654,16 +663,22 @@ conf_set (int transaction, char *section, char *tag,
 		xlog_warn("conf_set: strdup(\"%s\") failed", section);
 		goto fail;
 	}
+	upper2lower(node->section);
+
 	node->tag = strdup(tag);
 	if (!node->tag) {
 		xlog_warn("conf_set: strdup(\"%s\") failed", tag);
 		goto fail;
 	}
+	upper2lower(node->tag);
+
 	node->value = strdup(value);
 	if (!node->value) {
 		xlog_warn("conf_set: strdup(\"%s\") failed", value);
 		goto fail;
 	}
+	upper2lower(node->value);
+
 	node->override = override;
 	node->is_default = is_default;
 	return 0;
