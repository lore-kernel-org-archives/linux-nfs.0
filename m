From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 4] Use llseek instead of f_pos= for directory seeking.
Date: Mon, 16 Aug 2004 13:58:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BwYdv-0002Zr-8C@notabene.cse.unsw.edu.au>
References: <20040816135256.9819.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwYgD-0008Fr-7a
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:05 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BwYgB-0002ei-RY
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:04 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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


nfsd currently just sets f_pos when seeking in a directory.
This bypasses any checking and other handling that a filesystem
might want to do.

So instead, we use 'llseek' copied out of fs/read_write.c
use that, both to seek at the start, and the find the new position at
the end.

If it were not  too intrusive, would could export llseek as vfs_llseek as was
done in 2.6....

Thanks to
    "Derrick Schommer" <dschommer@acopia.com>
    "Trond Myklebust" <trond.myklebust@fys.uio.no>


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |   35 ++++++++++++++++++++++++++++-------
 1 files changed, 28 insertions(+), 7 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-08-16 09:54:04.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-08-16 09:54:28.000000000 +1000
@@ -586,6 +586,22 @@ found:
 	return ra;
 }
 
+/* copied from fs/read_write.c */
+static inline loff_t llseek(struct file *file, loff_t offset, int origin)
+{
+	loff_t (*fn)(struct file *, loff_t, int);
+	loff_t retval;
+
+	fn = default_llseek;
+	if (file->f_op && file->f_op->llseek)
+		fn = file->f_op->llseek;
+	lock_kernel();
+	retval = fn(file, offset, origin);
+	unlock_kernel();
+	return retval;
+}
+
+
 /*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
@@ -621,7 +637,7 @@ nfsd_read(struct svc_rqst *rqstp, struct
 		file.f_ralen = ra->p_ralen;
 		file.f_rawin = ra->p_rawin;
 	}
-	file.f_pos = offset;
+	llseek(&file, offset, 0);
 
 	oldfs = get_fs(); set_fs(KERNEL_DS);
 	err = file.f_op->read(&file, buf, *count, &file.f_pos);
@@ -706,7 +722,8 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	if (stable && !EX_WGATHER(exp))
 		file.f_flags |= O_SYNC;
 
-	file.f_pos = offset;		/* set write offset */
+
+	llseek(&file, offset, 0);
 
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
@@ -1398,10 +1415,12 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	err = nfsd_open(rqstp, fhp, S_IFDIR, MAY_READ, &file);
 	if (err)
 		goto out;
-	if (offset > ~(u32) 0)
-		goto out_close;
 
-	file.f_pos = offset;
+	offset = llseek(&file, offset, 0);
+	if (offset < 0) {
+		err = nfserrno((int)offset);
+		goto out_close;
+	}
 
 	/* Set up the readdir context */
 	memset(&cd, 0, sizeof(cd));
@@ -1429,11 +1448,13 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	/* If we didn't fill the buffer completely, we're at EOF */
 	eof = !cd.eob;
 
+
+	offset = llseek(&file, 0LL, 1);
 	if (cd.offset) {
 		if (rqstp->rq_vers == 3)
-			(void)xdr_encode_hyper(cd.offset, file.f_pos);
+			(void)xdr_encode_hyper(cd.offset, offset);
 		else
-			*cd.offset = htonl(file.f_pos);
+			*cd.offset = htonl(offset);
 	}
 
 	p = cd.buffer;


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
