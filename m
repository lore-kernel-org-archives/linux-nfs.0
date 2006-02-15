From: Bernd Strieder <strieder@informatik.uni-kl.de>
Subject: NFS mount in a changing network
Date: Wed, 15 Feb 2006 17:16:18 +0100
Message-ID: <200602151716.18601.strieder@informatik.uni-kl.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9PKM-0004KG-Hf
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:16:26 -0800
Received: from mailgate1.uni-kl.de ([131.246.120.5])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9PKK-0002RM-9I
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 08:16:26 -0800
Received: from christie.informatik.uni-kl.de (christie.informatik.uni-kl.de [131.246.16.32])
	by mailgate1.uni-kl.de (8.13.4/8.13.4/Debian-3) with ESMTP id k1FGGJfM016414
	for <nfs@lists.sourceforge.net>; Wed, 15 Feb 2006 17:16:19 +0100
Received: from forsyth.informatik.uni-kl.de (forsyth.informatik.uni-kl.de [131.246.16.56])
	by christie.informatik.uni-kl.de (Postfix) with ESMTP id 0817B14470B5
	for <nfs@lists.sourceforge.net>; Wed, 15 Feb 2006 17:16:18 +0100 (CET)
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

Hello,

a bunch of machines had to change their IP addresses, or said 
differently had to be moved into another IP network. One of the 
machines had a long-running job that should continue to run. This 
job (a theorem prover) had a log file on an NFS auto-mounted 
volume redirected to from stdout. The client machine uses kernel 
2.4.27, the server a SuSE kernel 2.4.21. Both are SuSE 9.0.

Due to the opened file, it was not possible to umount the volume, 
and remount it with new IP addresses.

So, just changing the IP address was no option, so I added the 
required new IP address to the interfaces of the server and the 
client and left the old address for the running mount. New mounts 
use the new addresses, the old mount continues to work. I had 
tried this some days before, and then, it seemed to work.

The process seemed to be running fine, it has over 200000 minutes 
of CPU since it was started, more than 100000 at the point the 
change happened. But somehow the log-file stopped to be written 
to, and I did not notice until a few days ago. The last write was 
in about the time the IP address changes were done, and the server 
was rebooted. The server booting should have made the client 
waiting until it returned.

The situation is as follows, observe the "(deleted)" for the log 
file.

 # ll /proc/22664/fd

dr-x------    2 user42 assis           0 2006-02-15 16:20 .
dr-xr-xr-x    3 user42 assis           0 2006-02-15 16:20 ..
lrwx------    1 user42 assis          64 2006-02-15 16:20 0 
-> /dev/pts/0 (deleted)
l-wx------    1 user42 assis          64 2006-02-15 16:20 1 
-> /home/user42/aaron/commendo.f0-5.cp.log.3 (deleted)
l-wx------    1 user42 assis          64 2006-02-15 16:20 2 
-> /home/user42/aaron/nohup.out

# ll /home/user42/aaron/commendo.f0-5.cp.log.3
-rw-r--r--    1 user42 assis    397473403 2006-01-10 
21:28 /home/user42/aaron/commendo.f0-5.cp.log.3

lsof does not list the file as being opened.

The mappings show a (deleted) too for the executable on the same 
NFS volume.

 # cat /proc/22664/maps
08048000-08101000 r-xp 00000000 00:0d 
12590679   /home/user42/WMS/NEWHEAD/Waldmeister/bin/WaldmeisterII.fast 
(deleted)
08101000-08106000 rw-p 000b8000 00:0d 
12590679   /home/user42/WMS/NEWHEAD/Waldmeister/bin/WaldmeisterII.fast 
(deleted)
08106000-0b331000 rwxp 00000000 00:00 0
40000000-40018000 r-xp 00000000 08:05 41943554   /lib/ld-2.3.2.so
40018000-40019000 rw-p 00017000 08:05 41943554   /lib/ld-2.3.2.so
40019000-40022000 rw-p 00000000 00:00 0
40032000-40054000 r-xp 00000000 08:05 
16777782   /lib/i686/libm.so.6
40054000-40055000 rw-p 00021000 08:05 
16777782   /lib/i686/libm.so.6
40055000-40181000 r-xp 00000000 08:05 
16777781   /lib/i686/libc.so.6
40181000-40186000 rw-p 0012c000 08:05 
16777781   /lib/i686/libc.so.6
40186000-402bc000 rw-p 00000000 00:00 0
....
97415000-a3d7c000 rw-p 5728f000 00:00 0
bfffc000-c0000000 rwxp ffffd000 00:00 0

Attaching gdb to the process and setting a breakpoint on printf, 
after calling ferror returning 1, it is clear that printf does not 
output anything. errno has the value 116 ESTALE.

How can this happen, an existing file gets into deleted status on 
the client, without anybody having issued an unlink or whatever? 
Or do stale filehandles finally result in deleted?

Since a large part of the log is missing the run finally is not 
worth anything and will be killed sometimes. I'm leaving it 
around, in the case some more information can still be gathered.

I don't know yet, whether my posting will be accepted, but please 
CC me, as I'm not yet subscribed to the list. I will check the 
archives, anyway.

Bernd Strieder


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
