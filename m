From: Steve Dickson <SteveD@redhat.com>
Subject: Disappearing NFS directories
Date: Wed, 27 Aug 2003 17:28:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F4D2272.1050003@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050302060306070802080602"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19s7p6-0002Aw-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 14:27:24 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19s7p5-0002sA-F7
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 14:27:23 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h7RLRFK04756
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 17:27:15 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------050302060306070802080602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

On a couple of 64 bit (mostly ia64 and ppc64) NFS
client machines, the contents of remotely mountd
directories would either disappear or not be
seen at all. Other clients mounting the same
filesystem to the same server are able to see
everything... After doing some experiments there
appears to be some issues with readdirplus caching.
Here is what I found:

If the blind client explicitly does an /bin/ls
on a file in the empty directory, the file is found.

If the blind client create a file in the
'empty' directory, all of the other file
reappear... which make sense because the first
thing nfs_create does is a nfs_zap_caches(dir);

But when the "blind" client /bin/touch the directory
(i.e. updates the atime) the files don't comeback
but the mtime on the directory is updated...

So basically it looks like there are two problems:
1) some type of race condition puts the client in this condition
2) the readdirplus cache is not being flush at the appropriate time....

I've attached a patch that I think will take care
of the second issue. Unfortunately these are production
machine so I have not been able to test this patch (yet).

I noticed in __nfs_refresh_inode() that the invalid flag
was being turned off when the WCC attrs matched up with
the current cache values. Now I'm not sure if this makes
sense wrt to the readdir cache because if
(NFS_CACHE_ISIZE(inode) != new_size) is true AND/OR
(NFS_CACHE_MTIME(inode) != new_mtime) is true
we really need to flush the cache... right?

So the patch does *not* turn off the invalid flag
the WCC attrs match and its a directory inode...


SteveD.





--------------050302060306070802080602
Content-Type: text/plain;
 name="linux-2.4.21-nfs-readdircache.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-readdircache.patch"

--- linux-2.4.21/fs/nfs/inode.c.diff	2003-08-27 12:44:13.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2003-08-27 16:02:52.000000000 -0400
@@ -1189,7 +1189,8 @@ __nfs_refresh_inode(struct inode *inode,
          */
         if ((fattr->valid & NFS_ATTR_WCC)
 	    && NFS_CACHE_ISIZE(inode) == fattr->pre_size
-	    && NFS_CACHE_MTIME(inode) == fattr->pre_mtime) {
+	    && NFS_CACHE_MTIME(inode) == fattr->pre_mtime
+		&& !S_ISDIR(inode->i_mode)) {
 		invalid = 0;
 	}
 

--------------050302060306070802080602--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
