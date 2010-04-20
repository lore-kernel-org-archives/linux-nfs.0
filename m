Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51300 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab0DTHWr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 03:22:47 -0400
Date: Tue, 20 Apr 2010 17:22:38 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: [PATCH] Should we expect close-to-open consistency on directories?
Message-ID: <20100420172238.520eaa89@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Trond et al,

It has come to my attention that NFS directories don't behave consistently
in terms of cache consistency.

If, on the client, you have a loop like:

 while true; do sleep 1; ls -l $dirname ; done

and then on the server you make changes to the named directory, there are
some cases where you will see changes promptly and some where you wont.

In particular, if $dirname is '.' or the name of an NFS mountpoint, then
changes can be delayed by up to acdirmax.  If it is any other path, i.e. with
a non-trivial path component that is in the NFS filesystem, then changes
are seen promptly.

This seems to me to relate to "close to open" consistency.  Of course with
directories the 'close' side isn't relevant, but I still think it should be
that when you open a directory it validates the 'change' attribute on that
directory over the wire.

However the Linux VFS never tells NFS when a directory is opened.  The
current correct behaviour for most directories is achieved through
d_revalidate == nfs_lookup_revalidate.

For '.' and mountpoints we need a different approach.  Possibly the VFS could
be changed to tell the filesystem when such a directory is opened.  However I
don't feel up to that at the moment.

An alternative is to do a revalidation in nfs_readdir as below.  i.e. when
readdir see f_pos == 0, it requests a revalidation of the page cache.
This has two problems:
1/ a seek before the first read would cause the revalidation to be skipped.
   This can be fixed by putting a similar test in nfs_llseek_dir, or maybe
   triggering off 'dir_cookie == NULL' rather than 'f_pos == 0'.
2/ A normal open/readdir sequence will validate a directory twice, once in the
   lookup and once in the readdir.  This is probably undesirable, but it is
   not clear to me how to fix it.


So: is it reasonable to view the current behaviour as 'wrong'?
    any suggestions on how to craft a less problematic fix?

Thanks,
NeilBrown

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a1f6b44..df4f0a6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -560,6 +560,9 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->entry = &my_entry;
 
 	nfs_block_sillyrename(dentry);
+	if (filp->f_pos == 0)
+		/* Force attribute validity at open */
+		NFS_I(inode)->cache_validity |= NFS_INO_REVAL_PAGECACHE;
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0)
 		goto out;
