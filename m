From: seb <seb-nfs@h3d.com>
Subject: mount freeze, acl system
Date: Mon, 22 Jul 2002 16:41:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D3C1992.7090403@h3d.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elvis.h3d.com ([195.167.192.132] helo=mail.h3d.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17WeNu-0004M7-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 07:42:02 -0700
Received: from smtp3.h3d.com (ATuileries-101-2-1-75.abo.wanadoo.fr [193.251.34.75])
	by mail.h3d.com (Postfix) with ESMTP id 6EAF3F9F1
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 16:41:59 +0200 (CEST)
Received: from h3d.com (unknown [192.168.201.21])
	by smtp3.h3d.com (Postfix) with ESMTP id AE191B006D
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 16:40:42 +0200 (CEST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi,

i have 2 bugs with nfs.
i recently installed 2 linux rh 7.3. one is 'the nfs test client'. one 
is mainly a samba server with acl support, all acl stuff (kernel, 
winbindd, nss, fileutils, e2fsprogs) is installed and seem work, windows 
users are happy :). On this server i have too configured a nfs server, 
the export directory is the same than root samba dir which has some 
special acl set, and there is no quota.

bug 1 :
on the client, after a successfuly nfs mount, when i try to access the 
mount dir, the process freeze and impossible to kill it. ex: ls /mnt -> 
freeze, kill -9 doesn't work, umount -f /mnt doesn't work.
i used first the redhat kernel, i have tried with last 2.4.19 + 
linux-2.4.19-NFS_ALL.dif patch, update nfs-utils to 1.0.1, same result.
don't think it will help, but i do some strace ls /mnt, many finish with :
lstat64("/mnt",  <unfinished ...>

known bug ? a bad nfs server should not permently block a client, patch 
? how can i kill these process without reboot ? is there something that 
i can do ?

bug 2 :
on the server, after a client successfuly does a mount, all 'basic' 
access (ls,cd but not samba) on the directory freeze the process as with 
the client, and the process is unkillable.
kernel is 2.4.18 + acl patch. but i haven't try NFS_ALL patch or to 
update nfs-utils 1.0.1.
strace ls /disk2 result :
stat64("/disk2", {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
open("/disk2", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 4
fstat64(4, {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
fcntl64(4, F_SETFD, FD_CLOEXEC)         = 0
brk(0x8060000)                          = 0x8060000
getdents64(0x4, 0x805db20, 0x1000, 0x805db20 <unfinished ...>

same questions, is there a patch ?? can i test something ?

my goal is not to have nfs acl (i know there is nfs4), just want 
correctly mount and copy files.

hope my english is not too bad.
seb



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
