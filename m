From: Gandalf <nfs_lists_sourceforge_net@siemens-mobiles.org>
Subject: can't read superblock, can't mount anything from server
Date: Sun, 12 Jun 2005 18:35:24 +0200
Message-ID: <42AC644C.4060001@siemens-mobiles.org>
Reply-To: nfs_lists_sourceforge_net@siemens-mobiles.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhVQs-00063M-1g
	for nfs@lists.sourceforge.net; Sun, 12 Jun 2005 09:35:34 -0700
Received: from mal35-2-82-225-70-234.fbx.proxad.net ([82.225.70.234] helo=server.local)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DhVQp-0005yZ-IO
	for nfs@lists.sourceforge.net; Sun, 12 Jun 2005 09:35:33 -0700
Received: from [192.168.2.3] (unknown [192.168.2.1])
	by server.local (Postfix) with ESMTP id 93CF2A3856
	for <nfs@lists.sourceforge.net>; Sun, 12 Jun 2005 18:35:24 +0200 (CEST)
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

Hey guys,

Problem:

i don't know why, but NFS suddenly stop working yesterday night, i
wanted to unmount my shared USB HDD so i stoped manually
nfs-kernel-server, and portmap, after i plug it (even after
server-client restarting) i keep getting the message

    wael@nasreddine:~$ sudo mount /media/WAEL_FAT/
    mount: 192.168.3.2:/media/WAEL_FAT: can't read superblock
    wael@nasreddine:~$ sudo mount -t nfs 192.168.3.2:/ /media/SERVER/
    mount: 192.168.3.2:/: can't read superblock



Information:
client:


    wael@nasreddine:~$ rpcinfo -p 192.168.3.2
       program vers proto   port
        100000    2   tcp    111  portmapper
        100000    2   udp    111  portmapper
        100003    2   udp   2049  nfs
        100003    3   udp   2049  nfs
        100003    4   udp   2049  nfs
        100003    2   tcp   2049  nfs
        100003    3   tcp   2049  nfs
        100003    4   tcp   2049  nfs
        100021    1   udp  32770  nlockmgr
        100021    3   udp  32770  nlockmgr
        100021    4   udp  32770  nlockmgr
        100021    1   tcp  32768  nlockmgr
        100021    3   tcp  32768  nlockmgr
        100021    4   tcp  32768  nlockmgr
        100005    1   udp    865  mountd
        100005    1   tcp    868  mountd
        100005    2   udp    865  mountd
        100005    2   tcp    868  mountd
        100005    3   udp    865  mountd
        100005    3   tcp    868  mountd
        100024    1   udp    603  status
        100024    1   tcp    606  status
    wael@nasreddine:~$
    wael@nasreddine:~$ ps -edf |grep po
    daemon    6543     1  0 13:51 ?        00:00:00 /sbin/portmap
    wael@nasreddine:~$ cat /etc/fstab
    192.168.3.2:/media/WAEL_FAT     /media/WAEL_FAT nfs
rw,hard,intr,noauto     0       0
    192.168.3.2:/   /media/SERVER   nfs     rw,hard,noauto  0       0
    192.168.3.2:/media/REDOUANE     /media/REDOUANE nfs
rw,hard,intr,noauto     0       0
    wael@nasreddine:~$ showmount -e 192.168.3.2
    Export list for 192.168.3.2:
    /               192.168.2.0/255.255.255.0,192.168.1.0/255.255.255.0
    /media/REDOUANE 192.168.2.0/255.255.255.0,192.168.1.0/255.255.255.0
    /media/WAEL_FAT
192.168.1.0/255.255.255.0,server.local,192.168.2.0/255.255.255.0



server:

    server:/etc# cat /etc/exports
    /       192.168.1.0/255.255.255.0(rw,sync)
192.168.2.0/255.255.255.0(rw,sync)

    /media/WAEL_FAT 192.168.1.0/255.255.255.0(rw,sync)
192.168.2.0/255.255.255.0(rw,sync)

    /media/REDOUANE 192.168.1.0/255.255.255.0(rw,sync)
192.168.2.0/255.255.255.0(rw,sync)
    server:/etc# cat hosts.allow
    portmap: 192.168.2.0/255.255.255.0 192.168.1.0/255.255.255.0
    mountd: 192.168.2.0/255.255.255.0 192.168.1.0/255.255.255.0
    rquotad: 192.168.2.0/255.255.255.0 192.168.1.0/255.255.255.0
    statd: 192.168.2.0/255.255.255.0 192.168.1.0/255.255.255.0
    server:/etc# cat hosts.deny
    portmap: ALL
    mountd: ALL
    rquotad: ALL
    statd: ALL
    server:/etc# cat fstab
    ### adding external Hard disks
    /dev/sda2       /media/WAEL_FAT vfat
defaults,auto,uid=1000,gid=1000,iocharset=utf8  0       0
    server:/etc# ls /media/WAEL_FAT/
    AuthorizationForm.doc  ClickHere.exe  ClickHere.ini  CRAZY FROG Axel
F .wma  gdiplus.dll  mmc  Redouane_merci wael  server.zip  wael  yvon


Question
what's going on, i tried almost everything, i can't get into the HDD
using NFS :o


Thanks in advance





-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
