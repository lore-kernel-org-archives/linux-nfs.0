From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 4 of 8 - Remove name_lookup.h that noone is using anymore.
Date: Thu, 25 Mar 2004 12:06:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKf-0007De-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKs-0006bd-1y
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKr-0007pd-Mw
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:05 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:06:59 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/name_lookup.h |   38 -----------------------------------
 1 files changed, 38 deletions(-)

diff ./include/linux/sunrpc/name_lookup.h~current~ ./include/linux/sunrpc/name_lookup.h
--- ./include/linux/sunrpc/name_lookup.h~current~	2004-03-25 11:43:32.000000000 +1100
+++ ./include/linux/sunrpc/name_lookup.h	1970-01-01 10:00:00.000000000 +1000
@@ -1,38 +0,0 @@
-
-/*
- * map between user/group name and id for a given 'client' 
- */
-
-struct name_ent {
-	char name[20];
-};
-static inline int name_get_user(int uid, struct name_ent **namep)
-{
-	struct name_ent *n = kmalloc(sizeof(*n),GFP_KERNEL);
-	if (n) sprintf(n->name, "%d",uid);
-	*namep = n;
-	return n ? 0 : -ENOMEM;
-}
-static inline int name_get_group(int uid, struct name_ent **namep)
-{
-	struct name_ent *n = kmalloc(sizeof(*n),GFP_KERNEL);
-	if (n) sprintf(n->name, "%d",uid);
-	*namep = n;
-	return n ? 0 : -ENOMEM;
-}
-static inline int name_get_uid(char *name, int name_len, int *uidp)
-{
-	*uidp = simple_strtoul(name, NULL, 0);
-	return 0;
-}
-
-static inline int name_get_gid(char *name, int name_len, int *gidp)
-{
-	*gidp = simple_strtoul(name, NULL, 0);
-	return 0;
-}
-
-static inline void name_put(struct name_ent *ent) 
-{
-	kfree(ent);
-}


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
