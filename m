From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 22:28:56 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098448136.21421.78.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <16760.31766.119716.302669@cse.unsw.edu.au>
	 <1098418326.21421.49.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/px8wfnHGMWZzqO5gZiT"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKyFZ-0002fq-17
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 05:10:29 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKyFY-0004P7-8w
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 05:10:28 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1098418326.21421.49.camel@hole.melbourne.sgi.com>
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


--=-/px8wfnHGMWZzqO5gZiT
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2004-10-22 at 14:12, Greg Banks wrote:
> I agree with your analysis...yet this same client code works against
> an IRIX server.  I'll grab some snoops and see what's happening on
> the wire in that case.

Well, that was instructive.  There seem to be several interesting
problems; the most obvious of which is that the dentry refcount
accounting in nfs_rename() is off by one, so that the client does
a sillyrename even when there *no* file descriptors open for the
target file.  This is actually what happens in the cthon test code
and I've verified it with a small test case.

At this point in the code there should be 1 refcount for being
connected to the dentry tree and 1 for the path lookup in sys_rename().
The attached patch changes the sillyrename threshold from 1 to 2.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--=-/px8wfnHGMWZzqO5gZiT
Content-Disposition: attachment; filename=gnb-nfs-rename-refcount
Content-Type: text/plain; name=gnb-nfs-rename-refcount; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

Fix dentry refcount accounting error which causes unnecessary
sillyrenames when renaming to an existing file.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>


Index: linux/fs/nfs/dir.c
===================================================================
--- linux.orig/fs/nfs/dir.c	2004-10-22 21:53:23.%N +1000
+++ linux/fs/nfs/dir.c	2004-10-22 21:53:46.%N +1000
@@ -1438,7 +1438,7 @@ static int nfs_rename(struct inode *old_
 		goto go_ahead;
 	if (S_ISDIR(new_inode->i_mode))
 		goto out;
-	else if (atomic_read(&new_dentry->d_count) > 1) {
+	else if (atomic_read(&new_dentry->d_count) > 2) {
 		int err;
 		/* copy the target dentry's name */
 		dentry = d_alloc(new_dentry->d_parent,

--=-/px8wfnHGMWZzqO5gZiT--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
