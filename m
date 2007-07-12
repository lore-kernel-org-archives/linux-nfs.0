From: Neil Brown <neilb@suse.de>
Subject: [PATCH/RFC] Return ENOSPC and EDQUOT for nfs writes earlier.
Date: Thu, 12 Jul 2007 10:12:48 +1000
Message-ID: <18069.29184.792156.782358@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8mIS-0003wF-Rg
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 17:12:46 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8mIV-00062N-Nk
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 17:12:44 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


When a write to a local filesystem hits a space limitation such as
filesystem-full or quota-exhausted, the write fails synchronously.
You get ENOSPC or EDQUOT immediately.

NFS cannot do that efficiently.

Currently, you don't get these errors until 'fsync' or 'close'.  That
is very different from local filesystem behaviour, and is less than
ideal.

The following patch causes these two errors to be returned through the
next write call once they are known about.

A possible extension would be to set a flag when we first get such an
error, clear it when a write succeeds, and while the flag is set, do
all writes synchronously.  This would be even closer to
local-filesystem semantics, but I'm not sure it is worth it.

Thoughts?

Thanks,
NeilBrown

Make NFS writes return ENOSPC and EDQUOT more promptly.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfs/file.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff .prev/fs/nfs/file.c ./fs/nfs/file.c
--- .prev/fs/nfs/file.c	2007-07-12 08:57:09.000000000 +1000
+++ ./fs/nfs/file.c	2007-07-12 09:56:58.000000000 +1000
@@ -367,6 +367,8 @@ const struct address_space_operations nf
 static ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
+	struct nfs_open_context *ctx =
+		(struct nfs_open_context *)iocb->ki_filp->private_data;
 	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
 	struct inode * inode = dentry->d_inode;
 	ssize_t result;
@@ -397,6 +399,16 @@ static ssize_t nfs_file_write(struct kio
 	if (!count)
 		goto out;
 
+	if (ctx->error == -EDQUOT || ctx->error == -ENOSPC) {
+		/* Local file systems return these errors synchronously,
+		 * NFS cannot do that efficiently, so just return them
+		 * at the first opportunity.
+		 */
+		result = ctx->error;
+		ctx->error = 0;
+		goto out;
+	}
+
 	nfs_add_stats(inode, NFSIOS_NORMALWRITTENBYTES, count);
 	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
 	/* Return error values for O_SYNC and IS_SYNC() */

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
