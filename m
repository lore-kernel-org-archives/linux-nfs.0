From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: nfs inode generation problem
Date: Wed, 18 Sep 2002 20:48:23 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1032349703.398088.395.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fla1aaj003.kng.mesh.ad.jp ([61.193.47.3] helo=yamt.dyndns.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rdKd-00080q-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 04:49:23 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

hi.

in export_iget, generation==0 means "ignore generation".
but it isn't safe because inode generation can be 0 actually.
(esp., on filesystems like xfs, which uses per-inode initially-0 generations.)

to fix it,
i think that we should have an additional flag for export_iget and get_dentry.
(ie. "ignore_generation" flag)

---
YAMAMOTO Takashi <yamamoto@valinux.co.jp>


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
