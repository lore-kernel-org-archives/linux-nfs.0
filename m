From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] statfs fails with EOVERFLOW
Date: Tue, 23 Mar 2004 14:05:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323130513.GB30984@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5lap-0007ez-B1
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:05:19 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5lao-0003pN-Mi
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:05:19 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 90D083539DC
	for <nfs@lists.sourceforge.net>; Tue, 23 Mar 2004 14:05:14 +0100 (CET)
To: nfs@lists.sourceforge.net
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


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

I am currently dealing with a 2.6 bug report concerning statfs failing
with EOVERFLOW. This happens on very large NFS file systems, and the
problem is obviously that by default, we set s_blocksize to the wtmult
value advertised by the server. If tbytes / wtmult exceeds 31 bits, statfs
will fail with EOVERFLOW (on 2.4 it would silently produce crap values).

There are several ways to deal with this. One is to require the admin
to explicitly use the bsize NFS mount option - the obvious drawback is
that mount(8) doesn't support this option yet. I will submit a patch
for this shortly, but that doesn't really cure things, because you still
cannot put that into say ab autofs map distributed over NIS without
updating all clients.

So the proper fix IMO is for the client to perform an fstat call select
the proper bsize based on the tbytes value. This can be done either in
user space or in the kernel.

I'm attaching a patch that does this in the kernel; the 2.4 equivalent
of this patch has been in our kernel for more than 6 months now, without
known adverse effects.

If Trond thinks this is a bad idea, I'd as happily provide a patch that
does the same in mount(8).

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-blocksize

--- linux-2.6.4/fs/nfs/inode.c.nocrash	2004-03-23 11:13:17.000000000 +0100
+++ linux-2.6.4/fs/nfs/inode.c	2004-03-23 11:28:18.000000000 +0100
@@ -279,12 +279,16 @@
 	struct nfs_server	*server;
 	struct inode		*root_inode = NULL;
 	struct nfs_fattr	fattr;
+	int			res;
 	struct nfs_fsinfo	fsinfo = {
 					.fattr = &fattr,
 				};
 	struct nfs_pathconf pathinfo = {
 			.fattr = &fattr,
 	};
+	struct nfs_fsstat fsstat = {
+			.fattr = &fattr
+	};
 
 	/* We probably want something more informative here */
 	snprintf(sb->s_id, sizeof(sb->s_id), "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
@@ -293,6 +297,10 @@
 
 	sb->s_magic      = NFS_SUPER_MAGIC;
 
+	res = server->rpc_ops->statfs(server, &server->fh, &fsstat);
+	if (res < 0)
+		return res;
+
 	root_inode = nfs_get_root(sb, &server->fh, &fsinfo);
 	/* Did getting the root inode fail? */
 	if (IS_ERR(root_inode))
@@ -319,6 +327,18 @@
 		} else
 			sb->s_blocksize = nfs_block_bits(fsinfo.wtmult,
 							 &sb->s_blocksize_bits);
+#if BITS_PER_LONG != 64
+		/* Prevent statfs from reporting incorrect file system sizes.
+		 * struct statfs holds the number of blocks in a long. A disk
+		 * of 2.8 TB and a wtmult value of 512 will produce a block count
+		 * that doesn't fit into 31 bits, causing statfs to fail with
+		 * EOVERFLOW.
+		 */
+		while ((fsstat.tbytes >> sb->s_blocksize_bits) >= 0x80000000ULL) {
+			sb->s_blocksize = nfs_block_bits(sb->s_blocksize * 2,
+							&sb->s_blocksize_bits);
+		}
+#endif
 	}
 
 	if (fsinfo.rtmax >= 512 && server->rsize > fsinfo.rtmax)

--IS0zKkzwUGydFO0o--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
