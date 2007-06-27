From: shichao <shichao@cn.fujitsu.com>
Subject: [NFS PATCH] Fix the issue of writing data over NFS
 concurrently both on client and Server uncorrectly
Date: Wed, 27 Jun 2007 11:33:38 +0800
Message-ID: <4681DA92.8020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
	"nfsv4@linux-nfs.org" <nfsv4@linux-nfs.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3OGp-0002Be-8A
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:32:43 -0700
Received: from [222.73.24.84] (helo=song.cn.fujitsu.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3OGr-0006fZ-C4
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:32:46 -0700
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

Hi everybody,

When I write data on file over NFS (mounted aync)  both on client and on Server, 
sometimes the client seems to miss the server's updated data and commit the stale cache data to the nfs server. This
leads to a file writed uncorrectly.

Example on a local dir /local/testdir/foo NFS-exported to the localhost on /nfs/foo:
 The exportfs option in server is: /nfs/  *(rw,sync,root_no_squash)

[root@rhel5~]# mount server:/nfs  /local/testdir

 My test program's main flow is as follows:
  1) fd = open("/local/testdir/foo", oflags, CHMOD_RW )
  2) wbuf="testmsg-1-"; write(fd, wbuf, strlen(wbuf))
  3) On nfs Server: echo "testmsg-2-" >> /nfs/foo    (using rsh)
  4) sleep(6); lseek(fd, 0L, SEEK_END)
  5) wbuf="testmsg-3-"; write(fd, wbuf, strlen(wbuf))
  6) lseek(fd, 0L, 0); read(fd, rbuf, MAX_DATA_SIZE)

 It is expected that the file data should be "testmsg-1-testmsg-2-testmsg-3",
 but in fact, after the program excuted, the file data is "testmsg-1-\0\0\0\0\0\0\0\0\0-testmsg-3".
 This problem just happens in the NFS mounted in the "sync" mode.

 I have investigated the problem and found the problem may be resolved by fixing the nfs_updatepage().

 When the lseek(fs,0L,SEEK_END) is invoked, the inode will be found invalid, and the nfs_revalidae_inode() will 
 update the flle size correctly, but the cache corresponding to the inode is not updately at the same time.
 Then at the final, the write(fd) write the "testmsg-3) from the update tail of the page cache, Because the NFS is mounted 
 in async mode, the write_updatepage just write the date in the local cache, do not commit the data to server in real time.
 In fact, the middle of the page cache of the inode is just filled with '\0'. 
 Finally, when the read(fd) is invoked, the nfsi->cache_validity is invalid and the local page cache is fresher than the cache sever,
 So the kernel commit all the local page cache to the server, as a result, the file on the sever is updated by the 
 invalid data "testmsg-1-\0\0\0\0\0\0\0\0\0-testmsg-3".

 To fix the problem, I think that the page cache should be checked in nfs_updatepage even in async mode. If the page is founded 
 that the nfsi->cache_validity is marked or the local inode->i_mtime and sever fattr.mtime is not the same, the kernel should 
 invoke the nfs_writepage_sync() to commit the writed data at real time.
 Then at the read(), even some stale cache data exists in the middle of the page cache, the nfsi->cache_validity is valid and the local page
 cache timestamp is the same as the cache sever, so the kernel will not commit the local invalid page cache to the server, 
 then finally the local page cache will be refreshed by the read with the correct file data on sever.
 
 I have made the patch attached below, it is confirmed the patch can fix the issue. 
 But I am still wonder that is the patch really reasonable and correct, or is the patch just not needed, this issue may can not
 be avoid in async in fact?
 
 Can somebody give your suggestion or other better fix method? 

Thanks

Regards.
ShiChao

Signed-off-by: ShiChao <shichao@cn.fujitsu.com>
--- linux/fs/nfs/write.c	2007-06-27 10:32:52.000000000 +0800
+++ linux-fix/fs/nfs/write.c	2007-06-27 10:29:55.000000000 +0800
@@ -836,6 +836,9 @@
 	struct inode	*inode = page->mapping->host;
 	struct nfs_page	*req;
 	int		status = 0;
+	int		result = 0 ;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_fattr fattr;
 
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
@@ -852,8 +855,27 @@
	if (IS_SYNC(inode)) {
		status = nfs_writepage_sync(ctx, inode, page, offset, count, 0);
		if (status > 0) {
			if (offset == 0 && status == PAGE_CACHE_SIZE)
				SetPageUptodate(page);
			return 0;
		}
		return status;
-	}
-
+	}else{
+			   if (nfsi->cache_validity & NFS_INO_INVALID_DATA) 
+                           {	
+			           status = nfs_writepage_sync(ctx, inode, page, offset, count, 0);
+			           if (status > 0) {
+				        if (offset == 0 && status == PAGE_CACHE_SIZE)
+					   SetPageUptodate(page);
+				        return 0;
+			           }
+			   }else if ( nfs_attribute_timeout(inode)){
+                           result = NFS_PROTO(inode)->getattr(NFS_SERVER(inode), NFS_FH(inode), &fattr); 
+	                     if (!timespec_equal(&inode->i_mtime, &fattr.mtime)){
+			            status = nfs_writepage_sync(ctx, inode, page, offset, count, 0);
+			           if (status > 0) {
+				        if (offset == 0 && status == PAGE_CACHE_SIZE)
+					   SetPageUptodate(page);
+				        return 0;
+			              }     
+			    }
+			}
+        }
 	/* If we're not using byte range locks, and we know the page
 	 * is entirely in cache, it may be more efficient to avoid
 	 * fragmenting write requests.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
