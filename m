From: michael <michael@newdream.net>
Subject: statd segfaults
Date: Mon, 17 Feb 2003 22:55:04 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E51D8C8.8000905@newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gollum.dreamhost.com ([66.33.209.16] ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18l1Qe-0002ba-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 22:40:32 -0800
Received: from newdream.net (bdsl.66.14.162.152.gte.net [66.14.162.152])
	by gollum.dreamhost.com (Postfix) with ESMTP id 9F62E5B763
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 22:40:01 -0800 (PST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

statd segfaults and has to be restarted.

Has anyone else experienced this behavior? have any suggestions? I have 
been able to find references to the problem in various list archives, 
but haven't been able to find a solution.

i can provide more information if need be.

thanks in advance,
michael

----

client:
debian 3.0
nfs-common_1.0.2-1_i386.deb
kernels: 2.2.19, 2.2.23, 2.4.20 using nfs patches and not

snipit from /etc/fstab:
10.7.99.15:/vol/vol0/swarthy/russian    /home/.russian  nfs 
defaults,intr,vers=3,rsize=8192,wsize=8192,bg   0 0
10.7.99.93:/vol/vol2/crummy/localbackups/medina /mnt/filerbackup 
nfs     defaults,intr,vers=3,rsize=8192,wsize=8192,bg   0 0
10.7.99.92:/vol/vol1/frothy/kindle      /home/.kindle   nfs 
defaults,intr,vers=3,rsize=8192,wsize=8192,bg   0 0


server:
Netapp F760 OS 6.3

the problem is happening on many machines with statd dying after 
anywhere from minutes to days.  I can include a complete strace if it 
would be useful... for now here are the last few lines of two:

1:

ioctl(6, 0x8913, 0xbffff5fc)            = 0
ioctl(6, 0x8915, 0xbffff5fc)            = 0
ioctl(6, 0x8913, 0xbffff5fc)            = 0
ioctl(6, 0x8915, 0xbffff5fc)            = 0
ioctl(6, 0x8913, 0xbffff5fc)            = 0
ioctl(6, 0x8915, 0xbffff5fc)            = 0
ioctl(6, 0x8913, 0xbffff5fc)            = 0
ioctl(6, 0x8915, 0xbffff5fc)            = 0
close(6)                                = 0
open("/var/lib/nfs/sm/10.7.99.14", O_WRONLY|O_CREAT|O_SYNC, 0600) = 6
close(6)                                = 0
time([1039462404])                      = 1039462404
write(2, "12/09/2002 11:33:24 rpc.statd[29"..., 7412/09/2002 11:33:24 
rpc.statd[29998]: MONITORING 10.7.99.14 for 127.0.0.1
) = 74
sendmsg(4, {msg_name(16)={sin_family=AF_INET, sin_port=htons(2670), 
sin_addr=inet_addr("127.0.0.1")}}, 
msg_iov(1)=[{"\336^\313\2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
32}], msg_controllen=24, msg_control=0x8051c20, , msg_flags=0}, 0) = 32
--- SIGSEGV (Segmentation fault) ---
+++ killed by SIGSEGV +++


2:

ioctl(6, 0x8915, 0xbffff60c)            = 0
ioctl(6, 0x8913, 0xbffff60c)            = 0
ioctl(6, 0x8915, 0xbffff60c)            = 0
ioctl(6, 0x8913, 0xbffff60c)            = 0
ioctl(6, 0x8915, 0xbffff60c)            = 0
ioctl(6, 0x8913, 0xbffff60c)            = 0
ioctl(6, 0x8915, 0xbffff60c)            = 0
ioctl(6, 0x8913, 0xbffff60c)            = 0
ioctl(6, 0x8915, 0xbffff60c)            = 0
ioctl(6, 0x8913, 0xbffff60c)            = 0
ioctl(6, 0x8915, 0xbffff60c)            = 0
close(6)                                = 0
open("/var/lib/nfs/sm/10.7.99.93", O_WRONLY|O_CREAT|O_SYNC, 0600) = 6
close(6)                                = 0
time([1039462125])                      = 1039462125
write(2, "12/09/2002 11:28:45 rpc.statd[70"..., 7312/09/2002 11:28:45 
rpc.statd[7097]: MONITORING 10.7.99.93 for 127.0.0.1
) = 73
sendmsg(4, {msg_name(16)={sin_family=AF_INET, sin_port=htons(1475), 
sin_addr=inet_addr("127.0.0.1")}}, 
msg_iov(1)=[{"\220\370\362\17\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 
32}], msg_controllen=24, msg_control=0x8050fb0, , msg_flags=0}, 0) = 32
--- SIGSEGV (Segmentation fault) ---
+++ killed by SIGSEGV +++


-----
keywords: statd dies dying segfault debian woody netapp nfs-common



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
