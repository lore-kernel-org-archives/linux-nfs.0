From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/2] NFS: Cache invalidation fixup
Date: Thu, 19 Oct 2006 17:03:58 -0400
Message-ID: <20061019210358.6797.62728.stgit@lade.trondhjem.org>
References: <1161291638.5506.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Miklos Szeredi <miklos@szeredi.hu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gaf5b-0000oI-M4
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 14:06:07 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gaf5c-0004VL-Ey
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 14:06:08 -0700
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <1161291638.5506.9.camel@lade.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If someone has renamed a directory on the server, triggering the d_move
code in d_materialise_unique(), then we need to invalidate the
cached directory information in the source parent directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2cfa414..fa71936 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -936,8 +936,14 @@ static struct dentry *nfs_lookup(struct 
 no_entry:
 	res = d_materialise_unique(dentry, inode);
 	if (res != NULL) {
+		struct dentry *parent;
 		if (IS_ERR(res))
 			goto out_unlock;
+		/* Was a directory renamed! */
+		parent = dget_parent(res);
+		if (!IS_ROOT(parent))
+			nfs_mark_for_revalidate(parent->d_inode);
+		dput(parent);
 		dentry = res;
 	}
 	nfs_renew_times(dentry);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
