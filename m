From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 12:56:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098413781.21421.37.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Qd1xD6JJXl4pVik4vCtK"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKpJh-0007mM-6J
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 19:38:09 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKpJg-0003ot-Mp
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 19:38:09 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041021161309.GC24417@fieldses.org>
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


--=-Qd1xD6JJXl4pVik4vCtK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

G'day,

[compendium reply]

On Thu, 2004-10-21 at 17:31, Trond Myklebust wrote: 
> to den 21.10.2004 Klokka 16:51 (+1000) skreiv Greg Banks:
> > G'day,
> > 
> > The attached patch forward ports from 2.4 the fix to nfs_rename()
> > which makes the nfsidem test in the Connectathon test suite pass.
> 
> 
> Vetoed.
> 
> This remains a server bug, not a client bug.

Agreed.  However we work around other server bugs, for example
IRIX server bugs which have been fixed for years and are not
seen on any SGI-supported IRIX box.  Why should a Linux server
bug be any different?

>  The default should NOT be
> no_subtree_check.

The default is "subtree_check".

> Besides, that patch will screw up on "nohide" partitions which may
> indeed cause 2 different files to have the same fileid.

Yes, and I should have seen that...the attached patch deals
with nohide by comparing the whole file handle instead of just
the fileid.

On Thu, 2004-10-21 at 17:40, Trond Myklebust wrote: 
> to den 21.10.2004 Klokka 17:51 (+1000) skreiv Greg Banks:
> > > 
> > > Vetoed.
> > 
> > I don't get it.  Why is this patch in 2.4?
> 
> It slipped in. That's not a reason to make the same mistake in 2.6.

Ok, let's slip it out again.  How about, when this is resolved, I
submit a patch which syncs 2.4 to the 2.6 solution?

On Fri, 2004-10-22 at 02:13, J. Bruce Fields wrote:
> We could do something like this for v4, though, couldn't we?
> 
> (I'm looking at rfc3530 section 9.3, which allows the client to assume
> two files are the same if the server returns the same fileid and fsid
> attributes for the two filehandles and doesn't return TRUE for
> unique_handles on either.)

While we're digging in RFCs, rfc1813 section 2.6 says:
> The client stores file handles for use in a later request and
> can compare two file handles from the same server for equality
> by doing a byte-by-byte comparison, but cannot otherwise interpret
> the contents of file handles. If two file handles from the same
> server are equal, they must refer to the same file, but if they
> are not equal, no conclusions can be drawn. [...] Clients should
> use file handle comparisons only to improve performance, not for
> correct behavior.

I think this justifies the apparoach in the attached patch for v3 too.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--=-Qd1xD6JJXl4pVik4vCtK
Content-Disposition: attachment; filename=gnb-nfs-rename-2
Content-Type: text/plain; name=gnb-nfs-rename-2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Fix nfs_rename() so the nfsidem test in the Connectathon test suite passes.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>


Index: linux/fs/nfs/dir.c
===================================================================
--- linux.orig/fs/nfs/dir.c	2004-10-04 14:35:26.%N +1000
+++ linux/fs/nfs/dir.c	2004-10-22 09:59:30.%N +1000
@@ -1409,7 +1409,7 @@ static int nfs_rename(struct inode *old_
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
-	int error = -EBUSY;
+	int error;
 
 	/*
 	 * To prevent any new references to the target during the rename,
@@ -1436,6 +1436,18 @@ static int nfs_rename(struct inode *old_
 	 */
 	if (!new_inode)
 		goto go_ahead;
+	/*
+	 * If target is a hard link to the source, then noop.
+	 * We compare the entire file handle instead of just
+	 * the fileid to handle the nohide case.   This test
+	 * is supposed to happen on the server, but some servers
+	 * are buggy.
+	 */
+	error = 0;
+	if (nfs_compare_fh(NFS_FH(new_inode), NFS_FH(old_inode)))
+		goto out;
+
+	error = -EBUSY;
 	if (S_ISDIR(new_inode->i_mode))
 		goto out;
 	else if (atomic_read(&new_dentry->d_count) > 1) {

--=-Qd1xD6JJXl4pVik4vCtK--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
