From: Steve Dickson <SteveD@redhat.com>
Subject: [NFS][PATCH] Making sure negative lookup entries don't exist
Date: Fri, 28 Jan 2005 13:47:49 -0500
Message-ID: <41FA88D5.6010904@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060205020903030201020007"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cub8a-0004hr-3Z
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 10:46:32 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cub8X-0007P5-5B
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 10:46:32 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j0SIkHIm019833
	for <nfs@lists.sourceforge.net>; Fri, 28 Jan 2005 13:46:17 -0500
Received: from [192.168.62.4] (vpn83-143.boston.redhat.com [172.16.83.143])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j0SIkHO27240
	for <nfs@lists.sourceforge.net>; Fri, 28 Jan 2005 13:46:17 -0500
To: linux-nfs <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.
--------------060205020903030201020007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a 2.4.28 patch that ensures negative cached dirents
do not exist by always doing an otw getattr to the server.
This does cause a small increase in getattrs (~3% from what
I saw in my testing) but it seems to me the price is worth it to
ensure the client does not lie about the existence of a file.

comments?

steved.

--------------060205020903030201020007
Content-Type: text/x-patch;
 name="linux-2.4.28-nfs-negcache.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.28-nfs-negcache.patch"

--- linux-2.4.28/fs/nfs/dir.c.orig	2004-08-07 19:26:06.000000000 -0400
+++ linux-2.4.28/fs/nfs/dir.c	2005-01-28 13:00:59.402239000 -0500
@@ -455,7 +455,11 @@ int nfs_lookup_verify_inode(struct inode
  */
 static inline int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry)
 {
-	if (!nfs_check_verifier(dir, dentry))
+	if (IS_ROOT(dentry))
+		return 1;
+	if (__nfs_revalidate_inode(NFS_SERVER(dir), dir))
+		return 1;
+	if (time_after(NFS_MTIME_UPDATE(dir), dentry->d_time))
 		return 1;
 	return time_after(jiffies, dentry->d_time + NFS_ATTRTIMEO(dir));
 }

--------------060205020903030201020007--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
