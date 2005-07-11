From: Olaf Kirch <okir@suse.de>
Subject: [PATCH fs/locks 0 of 3] Introduction
Date: Mon, 11 Jul 2005 12:32:32 +0200
Message-ID: <20050711103232.GF27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrvaX-0002fk-OD
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:37 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DrvaW-0000z9-Ep
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:37 -0700
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

I recently debugged various file NFS locking problems caused by an
application that would open and close files in one thread, and obtain
posix locks on these file in a second thread. Using a test app, I could
trigger a BUG() in locks_remove_flock within seconds, because there were
still POSIX locks attached to the filp by the time of the final fput().
In addition, stale locks would accumulate on the NFS server.

While this is arguably stupid behavior on the application's part, I think
the kernel should nevertheless not get confused by this. The following
three patches fix three separate issues

 1:	Fixes a miscompare when establishing a lock, which would
 	cause the same lock to be established twice.
 2:	locks_remove_posix would issue a single unlock call using
 	the tgid of the current process, which may not be the tgid
	of the lock. This will cause stale NFS locks not owned by anyone.
 3:	fix the above mentioned race condition

Cheers
Olaf
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
