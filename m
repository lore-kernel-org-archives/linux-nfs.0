From: michael <michael@hq.newdream.net>
Subject: repeatable statd segfault
Date: Thu, 04 Sep 2003 20:00:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F57FC44.9070208@hq.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19v6qz-0004KP-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 20:01:41 -0700
Received: from smaug.dreamhost.com ([66.33.209.15] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19v6qz-00043w-Cp
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 20:01:41 -0700
Received: from hq.newdream.net (inez.hq.newdream.net [66.33.200.139])
	by smaug.dreamhost.com (Postfix) with ESMTP id D0B755B81E
	for <nfs@lists.sourceforge.net>; Thu,  4 Sep 2003 20:01:25 -0700 (PDT)
To: NFS List <nfs@lists.sourceforge.net>
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

(gdb) run -Fd

Starting program: /usr/local/src/nfs-utils-1.0.5/utils/statd/statd -Fd
09/04/2003 19:44:57 statd[12873]: Version 1.0.5 Starting
09/04/2003 19:44:57 statd[12873]: Flags: No-Daemon Log-STDERR
09/04/2003 19:44:57 statd[12873]: statd running as root. chown 
/var/lib/nfs/sm to choose different user

09/04/2003 19:44:57 statd[12873]: New state: 15467
09/04/2003 19:44:57 statd[12873]: Waiting for client connections.

--> at this point i run  ./testlk /home/.raby/nfs_lock_test/blah
--> the file is mounted on a netapp 760 and the following happens:


--- Begin notify list dump ---
Entry 1: 10.3.19.5
--- End notify list dump ---
09/04/2003 19:45:12 statd[12873]: MONITORING 10.18.34.19 for gir

Program received signal SIGSEGV, Segmentation fault.
0x40119e3a in svc_getreqset () from /lib/libc.so.6
(gdb)

--> 10.18.34.19 is the netapp.

one question i have is, does /var/lib/nfs/sm/10.18.34.19 get unlinked 
after being created? it appears on occaision when i create a working 
lock, but then dissapears from the directory before the lock is released.

thanks!
michael





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
