From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 23] Check for existence of file_lock parameter inside of the kernel lock.
Date: Fri, 17 Dec 2004 16:23:55 +1100
Message-ID: <E1CfAap-0002dk-O0@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAb3-00058W-50
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAb0-000651-NT
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:09 -0800
To: Andrew Morton <akpm@osdl.org>
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



Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/locks.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff ./fs/locks.c~current~ ./fs/locks.c
--- ./fs/locks.c~current~	2004-12-15 11:57:12.000000000 +1100
+++ ./fs/locks.c	2004-12-15 11:57:12.000000000 +1100
@@ -1096,15 +1096,13 @@ static void time_out_leases(struct inode
 */
 void remove_lease(struct file_lock *fl)
 {
-	if (!IS_LEASE(fl))
-		return;
-
 	lock_kernel();
-
+	if (!fl || !IS_LEASE(fl))
+		goto out;
 	fl->fl_type = F_UNLCK | F_INPROGRESS;
 	fl->fl_break_time = jiffies - 10;
 	time_out_leases(fl->fl_file->f_dentry->d_inode);
-
+out:
 	unlock_kernel();
 }
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
