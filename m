From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 15 of 17 - get_int and get_expiry to help in parsing.
Date: Fri, 11 Oct 2002 15:27:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsL9-0003c1-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zshq-0004lZ-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:51:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Fri, 11 Oct 2002 15:51:18 +1000
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

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/cache.h |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+)

--- ./include/linux/sunrpc/cache.h	2002/10/11 03:09:10	1.6
+++ ./include/linux/sunrpc/cache.h	2002/10/11 03:19:49	1.7
@@ -275,4 +275,28 @@ extern void add_word(char **bpp, int *lp
 extern void add_hex(char **bpp, int *lp, char *buf, int blen);
 extern int get_word(char **bpp, char *dest, int bufsize);
 
+static inline int get_int(char **bpp, int *anint)
+{
+	char buf[50];
+	char *ep;
+	int rv;
+	int len = get_word(bpp, buf, 50);
+	if (len < 0) return -EINVAL;
+	if (len ==0) return -ENOENT;
+	rv = simple_strtol(buf, &ep, 0);
+	if (*ep) return -EINVAL;
+	*anint = rv;
+	return 0;
+}
+
+static inline time_t get_expiry(char **bpp)
+{
+	int rv;
+	if (get_int(bpp, &rv))
+		return 0;
+	if (rv < 0)
+		return 0;
+	return rv;
+}
+
 #endif /*  _LINUX_SUNRPC_CACHE_H_ */


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
