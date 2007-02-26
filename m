From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Hang when shutting down - seems umount and NFS related -
	kernel version 2.6.18.1
Date: Tue, 27 Feb 2007 00:04:19 +0100
Message-ID: <9a8748490702261504n147aa444y779153c03a2d44a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLotM-0000jz-LN
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 15:04:24 -0800
Received: from an-out-0708.google.com ([209.85.132.250])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLotN-0002DT-Em
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 15:04:26 -0800
Received: by an-out-0708.google.com with SMTP id d40so1726974and
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 15:04:24 -0800 (PST)
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

I have a server that has the sole job of serving up a bunch of NFS
filesystems to webservers. The server is running kernel 2.6.18.1

A few days ago when attempting to reboot the server, the shutdown
process hung with a backtrace on the console. A photo was taken and is
available here:
  http://www.kernel.org/pub/linux/kernel/people/juhl/images/DSC00504.jpg

A quick (incomplete) text transcript of the photo is here:

EIP: [<c01a51a0>] nfs_clear_inode+0x61/0x6b SS:ESP 0068:eb476ee4
BUG: warning at kernel/exit.c:855/do_exit()
 do_exit			do_trap
 do_trap			do_invalid_op
 do_invalid_op			nfs_clear_inode
 scheduler_tick			radix_tree_gang_lookup_tag
 nfs_wait_on_reques_locked	error_code
 nfs3_forget_cached_acls	nfs_clear_inode
 clear_inode			dispose_list
 invalidate_inodes		generic_shutdown_super
 kill_anon_super		nfs_kill_super
 deactivate_super		sys_umount
 sys_readlink			syscall_call
BUG: umount/20593, lock held at task exit time!
  {alloc_super}
.. held by:  umount:20593
... acquired at:     generic_shutdown_super
/etc/rc6.d/S01reboot: line4: 20593 Segmentation fault      $*
                                                          [FAILED]
Unmounting filesystems (retry):

The problem has only manifested itself this once, so unfortunately not
reproducible on demand, but I hope that maybe someone more
knowledgable of NFS internals than me can figure out what went wrong
and a way to fix it in the future (if it's not already fixed) :-)

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
