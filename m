From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 14 of 17 - Implement get_word to help in parsing cache updates
Date: Fri, 11 Oct 2002 15:27:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsL4-0003by-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsLX-0003iT-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:28:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:28:08 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: linux-kernel@vger.kernel.org
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

get_word understands both \x and \012 quoting styles.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |    1 
 ./net/sunrpc/cache.c           |   61 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

--- ./include/linux/sunrpc/cache.h	2002/10/11 03:04:45	1.5
+++ ./include/linux/sunrpc/cache.h	2002/10/11 03:09:10	1.6
@@ -273,5 +273,6 @@ extern void cache_drop(struct cache_deta
 
 extern void add_word(char **bpp, int *lp, char *str);
 extern void add_hex(char **bpp, int *lp, char *buf, int blen);
+extern int get_word(char **bpp, char *dest, int bufsize);
 
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */
--- ./net/sunrpc/cache.c	2002/10/11 03:04:46	1.5
+++ ./net/sunrpc/cache.c	2002/10/11 03:09:11	1.6
@@ -19,6 +19,7 @@
 #include <linux/kmod.h>
 #include <linux/list.h>
 #include <linux/module.h>
+#include <linux/ctype.h>
 #include <asm/uaccess.h>
 #include <linux/poll.h>
 #include <linux/proc_fs.h>
@@ -864,3 +865,63 @@ static int cache_make_upcall(struct cach
 	wake_up(&queue_wait);
 	return 0;
 }
+
+/*
+ * parse a message from user-space and pass it
+ * to an appropriate cache
+ * Messages are, like requests, separated into fields by
+ * spaces and dequotes as \xHEXSTRING or embedded \nnn octal
+ *
+ * Message is 
+ *   reply cachename expiry key ... content....
+ *
+ * key and content are both parsed by cache 
+ */
+
+#define isodigit(c) (isdigit(c) && c <= '7')
+int get_word(char **bpp, char *dest, int bufsize)
+{
+	/* return bytes copied, or -1 on error */
+	char *bp = *bpp;
+	int len = 0;
+
+	while (*bp == ' ') bp++;
+
+	if (bp[0] == '\\' && bp[1] == 'x') {
+		/* HEX STRING */
+		bp += 2;
+		while (isxdigit(bp[0]) && isxdigit(bp[1]) && len < bufsize) {
+			int byte = isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
+			bp++;
+			byte <<= 4;
+			byte |= isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
+			*dest++ = byte;
+			bp++;
+			len++;
+		}
+	} else {
+		/* text with \nnn octal quoting */
+		while (*bp != ' ' && *bp && len < bufsize-1) {
+			if (*bp == '\\' &&
+			    isodigit(bp[1]) && (bp[1] <= '3') &&
+			    isodigit(bp[2]) &&
+			    isodigit(bp[3])) {
+				int byte = (*++bp -'0');
+				bp++;
+				byte = (byte << 3) | (*bp++ - '0');
+				byte = (byte << 3) | (*bp++ - '0');
+				*dest++ = byte;
+				len++;
+			} else {
+				*dest++ = *bp++;
+				len++;
+			}
+		}
+		*dest = '\0';
+	}
+
+	*bpp = bp;
+	if (*bp == ' ' || *bp == '\n' || *bp == '\0')
+		return len;
+	return -1;
+}


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
