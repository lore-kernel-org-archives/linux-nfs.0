From: Jeff Layton <jtlayton@poochiereds.net>
Subject: [PATCH] 2.4 nfs cache consistency problem with mmap'ed files
Date: Fri, 07 Apr 2006 22:59:33 -0400
Message-ID: <1144465173.6389.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: marcelo.tosatti@cyclades.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FS3gI-0003gx-MC
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 20:00:10 -0700
Received: from imf20aec.mail.bellsouth.net ([205.152.59.68])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FS3gE-0006eb-92
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 20:00:10 -0700
Received: from ibm62aec.bellsouth.net ([72.148.41.34])
          by imf20aec.mail.bellsouth.net with ESMTP
          id <20060408025929.LBVP16763.imf20aec.mail.bellsouth.net@ibm62aec.bellsouth.net>
          for <nfs@lists.sourceforge.net>; Fri, 7 Apr 2006 22:59:29 -0400
To: nfs@lists.sourceforge.net
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

This problem was reported to Red Hat and while fixing it for RHEL3, I
noticed that it was also a problem in the 2.4 git tree. The steps to
reproduce are a bit convoluted, so hopefully I'm explaining this well
enough. Let me know if you need clarification:

1) on a server create a file in an exported directory with some data in
it:

$ echo 1 > testfile

2) on an NFS client have a program mmap the file and access the data via
the mmap (effectively loading the pagecache with data from the server),
then have the program go to sleep indefinitely.

3) on the server, make a change to the file:

$ echo 2 > testfile

4) on the client, have another process cause a read:

$ cat /nfs/mounted/directory/testfile

You'll get the originally cached data (the 1), since the file is still
mmap'ed. This is expected.

5) on the client, kill the program that has the file mmap'ed and cat the
file again. You will still get the original file contents (the "1"
here).

The file is no longer mmap'ed, the data in the file and the mtime has
changed since the last OTW read, but the client will not invalidate the
cache for subsequent reads.

What's happening is that in step 4, the __nfs_refresh_inode function
updates NFS_CACHE_MTIME. But, because the file is still mmap'ed,
invalidate_inode_pages is not completely successful. So on the next pass
through, it assumes the cached data is good when it isn't.

The attached patch fixes this by checking whether the clean_pages list
for the inode is empty after invalidate_inode_pages is called. If not,
then we set a new nfs_i flag (NFS_INO_MAPPED). Then, on the next pass
through this function, we check the status of this flag and if it's set,
we clear it and set invalid=1 so that the function will make another
attempt at invalidating the cache.

This fixed the problem on my test rig. Comments and/or suggestions are
welcome.

-- Jeff

-----------[snip]-----------

--- linux-2.4/fs/nfs/inode.c.nfs-cache-fix
+++ linux-2.4/fs/nfs/inode.c
@@ -1047,6 +1047,13 @@ __nfs_refresh_inode(struct inode *inode,
 		invalid = 0;
 	}
 
+	/* set the invalid flag if the last attempt at invalidating
+	 * the inode didn't empty the clean_pages list */
+	if ( NFS_FLAGS(inode) & NFS_INO_MAPPED) {
+		NFS_FLAGS(inode) &= ~NFS_INO_MAPPED;
+		invalid = 1;
+	}
+
 	/*
 	 * If we have pending writebacks, things can get
 	 * messy.
@@ -1092,6 +1099,12 @@ __nfs_refresh_inode(struct inode *inode,
 		NFS_ATTRTIMEO(inode) = NFS_MINATTRTIMEO(inode);
 		NFS_ATTRTIMEO_UPDATE(inode) = jiffies;
 		invalidate_inode_pages(inode);
+		if (! list_empty(&inode->i_mapping->clean_pages)) {
+			dfprintk(PAGECACHE,
+				 "NFS: clean_pages for %x/%d is not empty\n",
+				 inode->i_dev, inode->i_ino);
+			NFS_FLAGS(inode) |= NFS_INO_MAPPED;
+		}
 		memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
 	} else if (time_after(jiffies, NFS_ATTRTIMEO_UPDATE(inode)+NFS_ATTRTIMEO(inode))) {
 		if ((NFS_ATTRTIMEO(inode) <<= 1) > NFS_MAXATTRTIMEO(inode))
--- linux-2.4/include/linux/nfs_fs_i.h.nfs-cache-fix
+++ linux-2.4/include/linux/nfs_fs_i.h
@@ -85,6 +85,7 @@ struct nfs_inode_info {
 #define NFS_INO_REVALIDATING	0x0004		/* revalidating attrs */
 #define NFS_IS_SNAPSHOT		0x0010		/* a snapshot file */
 #define NFS_INO_FLUSH		0x0020		/* inode is due for flushing */
+#define NFS_INO_MAPPED		0x0040		/* page invalidation failed */
 
 /*
  * NFS lock info




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
