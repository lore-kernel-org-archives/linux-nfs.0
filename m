From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 8 - Stub support for name lookup
Date: Fri, 11 Oct 2002 10:05:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIx-0007e2-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZS-000873-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:26 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:18 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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

NFSv4 need to be able to make from user/group name
to user/group id.  This include file contains some
simple stubs to do this.  They will be replaced with
something that really works later.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/name_lookup.h |   38 +++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+)

--- ./include/linux/sunrpc/name_lookup.h	2002/10/10 23:20:09	1.1
+++ ./include/linux/sunrpc/name_lookup.h	2002/10/10 23:21:26	1.2
@@ -0,0 +1,38 @@
+
+/*
+ * map between user/group name and id for a given 'client' 
+ */
+
+struct name_ent {
+	char name[20];
+};
+static inline int name_get_user(int uid, struct name_ent **namep)
+{
+	struct name_ent *n = kmalloc(sizeof(*n),GFP_KERNEL);
+	if (n) sprintf(n->name, "%d",uid);
+	*namep = n;
+	return n ? 0 : -ENOMEM;
+}
+static inline int name_get_group(int uid, struct name_ent **namep)
+{
+	struct name_ent *n = kmalloc(sizeof(*n),GFP_KERNEL);
+	if (n) sprintf(n->name, "%d",uid);
+	*namep = n;
+	return n ? 0 : -ENOMEM;
+}
+static inline int name_get_uid(char *name, int name_len, int *uidp)
+{
+	*uidp = simple_strtoul(name, NULL, 0);
+	return 0;
+}
+
+static inline int name_get_gid(char *name, int name_len, int *gidp)
+{
+	*gidp = simple_strtoul(name, NULL, 0);
+	return 0;
+}
+
+static inline void name_put(struct name_ent *ent) 
+{
+	kfree(ent);
+}


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
