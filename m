From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] mount.nfs: add new string tokenizer facility
Date: Fri, 28 Sep 2007 16:36:30 -0400
Message-ID: <20070928203630.12851.38364.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbMZb-0006UJ-Hj
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:31 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbMZg-00074D-C6
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:36:36 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

To quote the strtok(3) man page: "Avoid using these functions."

OK.  We've created our own.  The main reason for this is that strtok(3)
doesn't handle quoted delimiters at all.  We need to handle this:

   context="foo,bar"

where 'context' is a single mount option that sets a token string that
possibly uses the same delimiter that the mount command uses to separate
options (that is, a comma).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am |    4 +
 utils/mount/token.c     |  157 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/token.h     |   29 +++++++++
 3 files changed, 188 insertions(+), 2 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 23e7ae9..cfee756 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,10 +9,10 @@ man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_nfs_SOURCES = mount.c error.c network.c fstab.c \
+mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
 		    nfsmount.c nfs4mount.c stropts.c\
 		    nfsumount.c \
-		    mount_constants.h error.h network.h fstab.h \
+		    mount_constants.h error.h network.h fstab.h token.h \
 		    nfs4_mount.h nfs_mount4.h stropts.h
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
diff --git a/utils/mount/token.c b/utils/mount/token.c
new file mode 100644
index 0000000..5ef9604
--- /dev/null
+++ b/utils/mount/token.c
@@ -0,0 +1,157 @@
+/*
+ * token.c -- tokenize strings, a la strtok(3)
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+/*
+ * We've constructed a simple string tokenizer that is better than
+ * strtok(3) in several ways:
+ *
+ * 1.  It doesn't interfere with ongoing tokenizations using strtok(3).
+ * 2.  It's re-entrant so we can nest tokenizations, if needed.
+ * 3.  It can handle double-quoted delimiters (needed for 'context="sd,fslj"').
+ * 4.  It doesn't alter the string we're tokenizing, so it can work
+ *     on write-protected strings as well as writable strings.
+ */
+
+
+#include <ctype.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+
+#include "token.h"
+
+
+struct tokenizer_state {
+	char *pos;
+	char delimiter;
+	int error;
+};
+
+static void find_next_nondelimiter(struct tokenizer_state *tstate)
+{
+	while (*tstate->pos != '\0' && *tstate->pos == tstate->delimiter)
+		tstate->pos++;
+}
+
+static size_t find_next_delimiter(struct tokenizer_state *tstate)
+{
+	size_t len = 0;
+	int quote_seen = 0;
+
+	while (*tstate->pos != '\0') {
+		if (*tstate->pos == '"')
+			quote_seen ^= 1;
+
+		if (!quote_seen && *tstate->pos == tstate->delimiter)
+			break;
+
+		len++;
+		tstate->pos++;
+	}
+
+	/* did the string terminate before the close quote? */
+	if (quote_seen) {
+		tstate->error = EINVAL;
+		return 0;
+	}
+
+	return len;
+}
+
+/**
+ * next_token - find the next token in a string and return it
+ * @tstate: pointer to tokenizer context object
+ *
+ * Returns the next token found in the current string.
+ * Returns NULL if there are no more tokens in the string,
+ * or if an error occurs.
+ *
+ * Side effect: tstate is updated
+ */
+char *next_token(struct tokenizer_state *tstate)
+{
+	char *token;
+	size_t len;
+
+	if (!tstate || !tstate->pos || tstate->error)
+		return NULL;
+
+	find_next_nondelimiter(tstate);
+	if (*tstate->pos == '\0')
+		goto fail;
+	token = tstate->pos;
+
+	len = find_next_delimiter(tstate);
+	if (len) {
+		token = strndup(token, len);
+		if (token)
+			return token;
+		tstate->error = ENOMEM;
+	}
+
+fail:
+	tstate->pos = NULL;
+	return NULL;			/* no tokens found in this string */
+}
+
+/**
+ * init_tokenizer - return an initialized tokenizer context object
+ * @string: pointer to C string
+ * @delimiter: single character that delimits tokens in @string
+ *
+ * Returns an initialized tokenizer context object
+ */
+struct tokenizer_state *init_tokenizer(char *string, char delimiter)
+{
+	struct tokenizer_state *tstate;
+
+	tstate = malloc(sizeof(*tstate));
+	if (tstate) {
+		tstate->pos = string;
+		tstate->delimiter = delimiter;
+		tstate->error = 0;
+	}
+	return tstate;
+}
+
+/**
+ * tokenizer_error - digs error value out of tokenizer context
+ * @tstate: pointer to tokenizer context object
+ *
+ */
+int tokenizer_error(struct tokenizer_state *tstate)
+{
+	return tstate ? tstate->error : 0;
+}
+
+/**
+ * end_tokenizer - free a tokenizer context object
+ * @tstate: pointer to tokenizer context object
+ *
+ */
+void end_tokenizer(struct tokenizer_state *tstate)
+{
+	free(tstate);
+}
diff --git a/utils/mount/token.h b/utils/mount/token.h
new file mode 100644
index 0000000..47762dc
--- /dev/null
+++ b/utils/mount/token.h
@@ -0,0 +1,29 @@
+/*
+ * token.h -- tokenize strings, a la strtok(3)
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+struct tokenizer_state;
+
+char *next_token(struct tokenizer_state *);
+struct tokenizer_state *init_tokenizer(char *, char);
+int tokenizer_error(struct tokenizer_state *);
+void end_tokenizer(struct tokenizer_state *);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
