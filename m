From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/5] VFS: Add support for the FL_ACCESS flag to
	flock_lock_file()
Date: Mon, 26 Jun 2006 19:30:10 -0400
Message-ID: <20060626233010.6059.52077.stgit@lade.trondhjem.org>
References: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv0Wx-0001qo-62
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:11 -0700
Received: from dh134.citi.umich.edu ([141.211.133.134] helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fv0Wx-0003Ke-8l
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:11 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
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

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/locks.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 50cb0a2..b0b41a6 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -739,6 +739,8 @@ static int flock_lock_file(struct file *
 	int found = 0;
 
 	lock_kernel();
+	if (request->fl_flags & FL_ACCESS)
+		goto find_conflict;
 	for_each_lock(inode, before) {
 		struct file_lock *fl = *before;
 		if (IS_POSIX(fl))
@@ -771,6 +773,7 @@ static int flock_lock_file(struct file *
 	if (found)
 		cond_resched();
 
+find_conflict:
 	for_each_lock(inode, before) {
 		struct file_lock *fl = *before;
 		if (IS_POSIX(fl))
@@ -784,6 +787,8 @@ static int flock_lock_file(struct file *
 			locks_insert_block(fl, request);
 		goto out;
 	}
+	if (request->fl_flags & FL_ACCESS)
+		goto out;
 	locks_copy_lock(new_fl, request);
 	locks_insert_lock(&inode->i_flock, new_fl);
 	new_fl = NULL;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
