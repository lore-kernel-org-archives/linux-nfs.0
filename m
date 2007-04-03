From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ROOT_NFS 2.6.20.4 kernel crash
Date: Tue, 03 Apr 2007 12:49:28 -0400
Message-ID: <1175618968.6838.28.camel@heimdal.trondhjem.org>
References: <57bc13580704030834n615eaf24tc3294e67916debcc@mail.gmail.com>
	<1175616131.6838.21.camel@heimdal.trondhjem.org>
	<57bc13580704030924y1574018ag4f67ac677206ce89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-9W1aEBkWliLLUIzPzzy8"
Cc: nfs@lists.sourceforge.net
To: Greg Bradner <greg.bradner@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYmCP-0002ry-R9
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:49:37 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19Evl9WsFiA4l2Wc3phZ2auu2qZ4LY+cuM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HYmCQ-0005Rp-Ee
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:49:40 -0700
In-Reply-To: <57bc13580704030924y1574018ag4f67ac677206ce89@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-9W1aEBkWliLLUIzPzzy8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-04-03 at 09:24 -0700, Greg Bradner wrote:
> On 4/3/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2007-04-03 at 08:34 -0700, Greg Bradner wrote:
> > > I have booted into my NFS-Root and am trying to partition a drive.
> > > But kernel is crashing while making dev names.
> >
> > I believe GregKH has queued up the fix for this for the next stable
> > release. See
> >
> > http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=commit;h=634707388baa440d9c9d082cfc4c950500c8952b
> >
> 
> I checked and that patch is already applied to the 2.6.20.4 kernel.

Ah. You are hitting the same thing in a setattr() call. OK. How about
the following additional patch?

Cheers
  Trond


--=-9W1aEBkWliLLUIzPzzy8
Content-Disposition: inline; filename=linux-2.5.21-000-fix_setattr_oops.dif
Content-Type: message/rfc822; name=linux-2.5.21-000-fix_setattr_oops.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 3 Apr 2007 12:47:01 -0400
NFS: Fix an Oops in nfs_setattr()
Subject: No Subject
Message-Id: <1175618968.6838.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

It looks like nfs_setattr() and nfs_rename() also need to test whether the
target is a regular file before calling nfs_wb_all()...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c   |    3 ++-
 fs/nfs/inode.c |    6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 92d8ec8..cd34697 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1684,7 +1684,8 @@ go_ahead:
 	 * ... prune child dentries and writebacks if needed.
 	 */
 	if (atomic_read(&old_dentry->d_count) > 1) {
-		nfs_wb_all(old_inode);
+		if (S_ISREG(old_inode->i_mode))
+			nfs_wb_all(old_inode);
 		shrink_dcache_parent(old_dentry);
 	}
 	nfs_inode_return_delegation(old_inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 93d046c..44aa9b7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -341,8 +341,10 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	lock_kernel();
 	nfs_begin_data_update(inode);
 	/* Write all dirty data */
-	filemap_write_and_wait(inode->i_mapping);
-	nfs_wb_all(inode);
+	if (S_ISREG(inode->i_mode)) {
+		filemap_write_and_wait(inode->i_mapping);
+		nfs_wb_all(inode);
+	}
 	/*
 	 * Return any delegations if we're going to change ACLs
 	 */

--=-9W1aEBkWliLLUIzPzzy8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-9W1aEBkWliLLUIzPzzy8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-9W1aEBkWliLLUIzPzzy8--
