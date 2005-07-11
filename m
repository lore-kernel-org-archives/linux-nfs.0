From: Olaf Kirch <okir@suse.de>
Subject: [PATCH fs/locks 1 of 3] Fix miscompare in __posix_lock_file
Date: Mon, 11 Jul 2005 12:32:45 +0200
Message-ID: <20050711103245.GG27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drvah-0002g0-8t
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:47 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drvah-00011Y-0N
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:47 -0700
To: nfs@lists.sourceforge.net, akpm@osdl.org
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

# Subject: Fix miscompare in __posix_lock_file
# 
# If an application requests the same lock twice, the
# kernel should just leave the existing lock in place.
# Currently, it will install a second lock of the same type.
# 
# Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.12/fs/locks.c
===================================================================
--- linux-2.6.12.orig/fs/locks.c	2005-07-11 12:15:59.000000000 +0200
+++ linux-2.6.12/fs/locks.c	2005-07-11 12:16:41.000000000 +0200
@@ -828,12 +828,16 @@ static int __posix_lock_file(struct inod
 		/* Detect adjacent or overlapping regions (if same lock type)
 		 */
 		if (request->fl_type == fl->fl_type) {
+			/* In all comparisons of start vs end, use
+			 * "start - 1" rather than "end + 1". If end
+			 * is OFFSET_MAX, end + 1 will become negative.
+			 */
 			if (fl->fl_end < request->fl_start - 1)
 				goto next_lock;
 			/* If the next lock in the list has entirely bigger
 			 * addresses than the new one, insert the lock here.
 			 */
-			if (fl->fl_start > request->fl_end + 1)
+			if (fl->fl_start - 1 > request->fl_end)
 				break;
 
 			/* If we come here, the new and old lock are of the
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
