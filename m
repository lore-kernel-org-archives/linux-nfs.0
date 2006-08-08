From: Neil Brown <neilb@suse.de>
Subject: Can we flush directory data when the ctime changes?
Date: Tue, 8 Aug 2006 17:26:58 +1000
Message-ID: <17624.15554.514216.623190@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GALzV-0000g9-DP
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 00:27:05 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GALzV-00026Y-CD
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 00:27:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


Hi,
 We have a scenario where readdir in the linux client gets confused by 
responses from a Netapp fileserver.

What happens is that a readdir collects and caches the directory.
Then a subsequent readdir finds the first page is still in the cache
but the second page is missing.
The nfs client uses a cookie from the first page to request subsequent
entries and received a list of entries starting from the beginning of
the directory rather than from the point that it was up to.   It seems
that the cookies have changed.

The GETATTR call that the client makes to validate the cache reports
that the mtime hasn't change, *but the ctime has*.

I patched the (SLES9) kernel to invalidate the cache for directories
when the ctime changes and this fixed the problem (which was quite
repeatable). 

While it seems that it should be necessary to flush the dir cache on a
ctime change, it doesn't seem harmful either.

So: would it be acceptable to do this.  The following patch should
achieve this in current -mm (which is quite different from the 2.6.5
kernel where I tested this).

In case it is interesting, I have this commentary from one of our
support personnel.  I'm not sure if the content comes from someone at
Netapp or elsewhere, but it sounds plausible.

Thanks,
NeilBrown

  ......

  For example, NetApp filer support NFS but their file system is not
  simply a true unix/linux style file system.  They emulate that for
  NFS purposes but they also handle the file system in special ways
  for account for CIFS and other access.

  Things go on like files name conversions to unicode, for other name
  spaces.  These events can take place at much later times than the
  original file name creation through NFS.  This results in changes in
  the ctime stamp, without changes to mtime, and it also results in
  new cookie indexes being generated for the NFS file system.  If an
  NFS client does not invalidate it's cache upon such a condition, if
  can result in inconsistent cache information, as it has in the
  example for which this bug report was filed.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfs/inode.c |    5 +++++
 1 file changed, 5 insertions(+)

diff .prev/fs/nfs/inode.c ./fs/nfs/inode.c
--- .prev/fs/nfs/inode.c	2006-08-08 17:03:15.000000000 +1000
+++ ./fs/nfs/inode.c	2006-08-08 17:04:48.000000000 +1000
@@ -943,6 +943,11 @@ static int nfs_update_inode(struct inode
 	/* If ctime has changed we should definitely clear access+acl caches */
 	if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
 		invalid |= NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+		if (S_ISDIR(inode->i_mode))
+			/* Some servers (netapp) can change cookies when the
+			 * ctime changes, without changing mtime...
+			 */
+			invalid |= NFS_INO_INVALID_DATA;
 		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
 		nfsi->cache_change_attribute = jiffies;
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
