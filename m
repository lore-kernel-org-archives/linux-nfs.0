From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [patch 4/4] NFS: Remove use of the Big Kernel Lock around
	nfs	calls to readlink
Date: Tue, 17 Oct 2006 10:24:42 -0700
Message-ID: <1161105882.3315.24.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZsgV-0001AN-7Y
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:24:59 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZsgS-0000Km-VC
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 10:25:00 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HHObuM024958
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 13:24:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9HHObSi513334
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9HHObHh021438
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:37 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9HHOaR4021363
	for <nfs@lists.sourceforge.net>; Tue, 17 Oct 2006 11:24:37 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

Remove use of the Big Kernel Lock around indirect calls to
nfs3_proc_readlink and nfs4_proc_readlink, both of which
basically call rpc_call_sync.

Signed-off-by: Frank Filz <ffilz@us.ibm.com>

### Diffstat output
 symlink.c |    2 --
 1 files changed, 2 deletions(-)

diff --git a/fs/nfs/symlink.c b/fs/nfs/symlink.c
index 600bbe6..6c68611 100644
--- a/fs/nfs/symlink.c
+++ b/fs/nfs/symlink.c
@@ -33,9 +33,7 @@ static int nfs_symlink_filler(struct ino
 {
 	int error;
 
-	lock_kernel();
 	error = NFS_PROTO(inode)->readlink(inode, page, 0, PAGE_SIZE);
-	unlock_kernel();
 	if (error < 0)
 		goto error;
 	SetPageUptodate(page);



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
