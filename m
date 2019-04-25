Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C365C4321A
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11596206BA
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728694AbfDYOE0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:04:26 -0400
Received: from fieldses.org ([173.255.197.46]:50954 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728053AbfDYOEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:04:25 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id F10442499; Thu, 25 Apr 2019 10:04:22 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        jlayton@redhat.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/10] nfsd: expose some more information about NFSv4 opens
Date:   Thu, 25 Apr 2019 10:04:19 -0400
Message-Id: <1556201060-7947-10-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Add open modes, device numbers, inode numbers, and open owners to each
line of nfsd/clients/#/opens.

Open owners are totally opaque but seem to sometimes have some useful
ascii strings included, so passing through printable ascii characters
and escaping the rest seems useful while still being machine-readable.
---
 fs/nfsd/nfs4state.c            | 40 ++++++++++++++++++++++++++++------
 fs/nfsd/state.h                |  2 +-
 fs/seq_file.c                  | 17 +++++++++++++++
 include/linux/seq_file.h       |  2 ++
 include/linux/string_helpers.h |  1 +
 lib/string_helpers.c           |  5 +++--
 6 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 829d1e5440d3..f53621a65e60 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -42,6 +42,7 @@
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/jhash.h>
+#include <linux/string_helpers.h>
 #include "xdr4.h"
 #include "xdr4cb.h"
 #include "vfs.h"
@@ -2261,16 +2262,41 @@ static void opens_stop(struct seq_file *s, void *v)
 static int opens_show(struct seq_file *s, void *v)
 {
 	struct nfs4_stid *st = v;
-	struct nfs4_ol_stateid *os;
-	u64 stateid;
+	struct nfs4_ol_stateid *ols;
+	struct nfs4_file *nf;
+	struct file *file;
+	struct inode *inode;
+	struct nfs4_stateowner *oo;
+	unsigned int access, deny;
 
 	if (st->sc_type != NFS4_OPEN_STID)
 		return 0; /* XXX: or SEQ_SKIP? */
-	os = openlockstateid(st);
-	/* XXX: get info about file, etc., here */
+	ols = openlockstateid(st);
+	oo = ols->st_stateowner;
+	nf = st->sc_file;
+	file = find_any_file(nf);
+	inode = d_inode(file->f_path.dentry);
+
+	seq_printf(s, STATEID_FMT, STATEID_VAL(&st->sc_stateid));
+
+	access = bmap_to_share_mode(ols->st_access_bmap);
+	deny   = bmap_to_share_mode(ols->st_deny_bmap);
+
+	seq_printf(s, "\t\%s\%s",
+		access & NFS4_SHARE_ACCESS_READ ? "r" : "-",
+		access & NFS4_SHARE_ACCESS_WRITE ? "w" : "-");
+	seq_printf(s, "\t\%s\%s",
+		deny & NFS4_SHARE_ACCESS_READ ? "R" : "-",
+		deny & NFS4_SHARE_ACCESS_WRITE ? "W" : "-");
+
+	seq_printf(s, "\t%02x:%02x:%ld\t", MAJOR(inode->i_sb->s_dev),
+					 MINOR(inode->i_sb->s_dev),
+					 inode->i_ino);
+	seq_printf(s, "'");
+	seq_escape_mem(s, oo->so_owner.data, oo->so_owner.len,
+			ESCAPE_NP|ESCAPE_HEX|ESCAPE_NOHIGH, NULL);
+	seq_printf(s, "'\n");
 
-	memcpy(&stateid, &st->sc_stateid, sizeof(stateid));
-	seq_printf(s, "stateid: %llx\n", stateid);
 	return 0;
 }
 
@@ -2320,7 +2346,7 @@ static const struct file_operations client_opens_fops = {
 
 static const struct tree_descr client_files[] = {
 	[0] = {"info", &client_info_fops, S_IRUSR},
-	[1] = {"open", &client_opens_fops, S_IRUSR},
+	[1] = {"opens", &client_opens_fops, S_IRUSR},
 	[2] = {""},
 };
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5a999e4b766e..4db22433be82 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -56,7 +56,7 @@ typedef struct {
 	stateid_opaque_t        si_opaque;
 } stateid_t;
 
-#define STATEID_FMT	"(%08x/%08x/%08x/%08x)"
+#define STATEID_FMT	"%08x/%08x/%08x/%08x"
 #define STATEID_VAL(s) \
 	(s)->si_opaque.so_clid.cl_boot, \
 	(s)->si_opaque.so_clid.cl_id, \
diff --git a/fs/seq_file.c b/fs/seq_file.c
index 1dea7a8a5255..bb646e0c5b9c 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -383,6 +383,23 @@ void seq_escape(struct seq_file *m, const char *s, const char *esc)
 }
 EXPORT_SYMBOL(seq_escape);
 
+/**
+ * seq_escape_mem - copy data to buffer, escaping some characters
+ *
+ * See string_escape_mem for explanations of the arguments.
+ */
+void seq_escape_mem(struct seq_file *m, const char *src, size_t isz,
+		    unsigned int flags, const char *only)
+{
+	char *buf;
+	size_t size = seq_get_buf(m, &buf);
+	int ret;
+
+	ret = string_escape_mem(src, isz, buf, size, flags, only);
+	seq_commit(m, ret < size ? ret : -1);
+}
+EXPORT_SYMBOL(seq_escape_mem);
+
 void seq_vprintf(struct seq_file *m, const char *f, va_list args)
 {
 	int len;
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index a121982af0f5..de6ace9e5e6b 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -127,6 +127,8 @@ void seq_put_hex_ll(struct seq_file *m, const char *delimiter,
 		    unsigned long long v, unsigned int width);
 
 void seq_escape(struct seq_file *m, const char *s, const char *esc);
+void seq_escape_mem(struct seq_file *m, const char *src, size_t isz,
+		    unsigned int flags, const char *only);
 
 void seq_hex_dump(struct seq_file *m, const char *prefix_str, int prefix_type,
 		  int rowsize, int groupsize, const void *buf, size_t len,
diff --git a/include/linux/string_helpers.h b/include/linux/string_helpers.h
index d23c5030901a..54034526aa46 100644
--- a/include/linux/string_helpers.h
+++ b/include/linux/string_helpers.h
@@ -50,6 +50,7 @@ static inline int string_unescape_any_inplace(char *buf)
 #define ESCAPE_NP		0x10
 #define ESCAPE_ANY_NP		(ESCAPE_ANY | ESCAPE_NP)
 #define ESCAPE_HEX		0x20
+#define ESCAPE_NOHIGH		0x40
 
 int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		unsigned int flags, const char *only);
diff --git a/lib/string_helpers.c b/lib/string_helpers.c
index 29c490e5d478..2c3e7b93775e 100644
--- a/lib/string_helpers.c
+++ b/lib/string_helpers.c
@@ -511,8 +511,9 @@ int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		 * In these cases we just pass through a character to the
 		 * output buffer.
 		 */
-		if ((flags & ESCAPE_NP && isprint(c)) ||
-		    (is_dict && !strchr(only, c))) {
+		if ((  (flags & ESCAPE_NP && isprint(c)) ||
+		       (is_dict && !strchr(only, c))) &&
+		    !(flags & ESCAPE_NOHIGH && (unsigned char)c > 127)) {
 			/* do nothing */
 		} else {
 			if (flags & ESCAPE_SPACE && escape_space(c, &p, end))
-- 
2.20.1

