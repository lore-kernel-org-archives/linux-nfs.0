From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 9] Return EACCES instead of ESTALE for certain filehandle lookup failures
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00042q-11@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-00004z-FI
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uM-0004TJ-SV
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
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


As 'nfs_acceptable' uses the authnetication user in it's checks,
the filehandle might not be truely "stale" - EACCES is safer.

Thanks Olaf Kirch <okir@suse.de> and others.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/exportfs/expfs.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

diff ./fs/exportfs/expfs.c~current~ ./fs/exportfs/expfs.c
--- ./fs/exportfs/expfs.c~current~	2004-09-03 11:34:26.000000000 +1000
+++ ./fs/exportfs/expfs.c	2004-09-03 11:37:53.000000000 +1000
@@ -283,7 +283,12 @@ find_exported_dentry(struct super_block 
 
 	/* drat - I just cannot find anything acceptable */
 	dput(result);
-	return ERR_PTR(-ESTALE);
+	/* It might be justifiable to return ESTALE here,
+	 * but the filehandle at-least looks reasonable good
+	 * and it just be a permission problem, so returning
+	 * -EACCESS is safer
+	 */
+	return ERR_PTR(-EACCES);
 
  err_target:
 	dput(target_dir);


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
