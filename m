From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 10:19:49 -0500
Message-ID: <1134141589.8007.35.camel@lade.trondhjem.org>
References: <438B9C44.4030305@google.com>
	 <1133225130.12178.9.camel@lade.trondhjem.org> <438E4CA7.2050405@google.com>
	 <1133399727.8267.11.camel@lade.trondhjem.org> <43978AD2.8020000@google.com>
		 <1134013082.8002.8.camel@lade.trondhjem.org> <43998F4C.6010902@redhat.com>
	 <1134137783.8007.24.camel@lade.trondhjem.org> <439993B0.90801@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-h0pMDHci5VrGDySB4WRp"
Cc: Vince Busam <vbusam@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ekk2n-0004cJ-14
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 07:20:21 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ekk2l-0000H0-7J
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 07:20:21 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <439993B0.90801@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
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


--=-h0pMDHci5VrGDySB4WRp
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-12-09 at 09:24 -0500, Peter Staubach wrote:

> >One alternative would be to flush dirty data to the server on every call
> >to stat(), but that would slow it down considerably.
> >
> 
> Yes, to this last, but this is how most NFS implementations that I have seen
> conform to the requirment that write(2) cause the mtime to be updated.  The
> use of UNSTABLE NFSv3/NFSv4 writes can help as well as limiting the amount
> of dirty data that the client allows to be cached.

My main concern is that it will hit commands like 'ls -l' _hard_. The
latter will, for instance, be forced to wait until all pending writes on
all files in the directory have been flushed out. I'm not sure that
strict POSIX compatibility is worth that kind of hit.

Anyhow, the attached patch implements it. Lets try it out, and see how
it does. Definitely _not_ a 2.6.15 candidate, though.

> The client should _definitely_ not be setting the mtime itself.  The 
> file times
> are always managed by the server.

Agreed.

Cheers,
  Trond

--=-h0pMDHci5VrGDySB4WRp
Content-Disposition: inline; filename=linux-2.6.15-35-write_updates_mtime.dif
Content-Type: text/plain; name=linux-2.6.15-35-write_updates_mtime.dif; charset=utf-8
Content-Transfer-Encoding: 7bit

NFS: Make stat() return updated mtimes after a write()

 The SuS states that a call to write() will cause mtime to be updated on
 the file. In order to satisfy that requirement, we need to flush out
 any cached writes in nfs_getattr().
 Speed things up slightly by not committing the writes.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |    2 ++
 fs/nfs/write.c         |   23 ++++++++++++-----------
 include/linux/nfs_fs.h |    1 +
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index acde2c5..2c7f8aa 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -952,6 +952,8 @@ int nfs_getattr(struct vfsmount *mnt, st
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
+	/* Flush out writes to the server in order to update c/mtime */
+	nfs_sync_inode(inode, 0, 0, FLUSH_WAIT|FLUSH_NOCOMMIT);
 	if (__IS_FLG(inode, MS_NOATIME))
 		need_atime = 0;
 	else if (__IS_FLG(inode, MS_NODIRATIME) && S_ISDIR(inode->i_mode))
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ce0c20..9449b68 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1377,22 +1377,23 @@ int nfs_commit_inode(struct inode *inode
 int nfs_sync_inode(struct inode *inode, unsigned long idx_start,
 		  unsigned int npages, int how)
 {
-	int	error,
-		wait;
+	int nocommit = how & FLUSH_NOCOMMIT;
+	int wait = how & FLUSH_WAIT;
+	int error;
 
-	wait = how & FLUSH_WAIT;
-	how &= ~FLUSH_WAIT;
+	how &= ~(FLUSH_WAIT|FLUSH_NOCOMMIT);
 
 	do {
-		error = 0;
-		if (wait)
+		if (wait) {
 			error = nfs_wait_on_requests(inode, idx_start, npages);
-		if (error == 0)
-			error = nfs_flush_inode(inode, idx_start, npages, how);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-		if (error == 0)
+			if (error != 0)
+				continue;
+		}
+		error = nfs_flush_inode(inode, idx_start, npages, how);
+		if (error != 0)
+			continue;
+		if (!nocommit)
 			error = nfs_commit_inode(inode, how);
-#endif
 	} while (error > 0);
 	return error;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d38010b..408d82d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -62,6 +62,7 @@
 #define FLUSH_STABLE		4	/* commit to stable storage */
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
+#define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
 
 #ifdef __KERNEL__
 

--=-h0pMDHci5VrGDySB4WRp--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
