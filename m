From: ronald rojas <alsonsdev_mis@dctech.com.ph>
Subject: nfs problem: nfs could be mounted and viewed but errors on file
 opening
Date: Fri, 10 Sep 2004 13:50:37 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094795240.3169.17.camel@roach.aldevinco.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5i3h-0005L8-Tm
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 02:51:09 -0700
Received: from [203.177.36.194] (helo=lafleur.dctech.com.ph)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5eI4-0003HN-Gx
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 22:49:50 -0700
Received: from localhost (localhost [127.0.0.1])
	by lafleur.dctech.com.ph (Postfix on SuSE Linux eMail Server 3.0) with ESMTP id 7806F21B2F8
	for <nfs@lists.sourceforge.net>; Fri, 10 Sep 2004 14:00:32 +0800 (PHT)
Received: from [202.133.204.114] (unknown [202.133.204.114])
	by lafleur.dctech.com.ph (Postfix on SuSE Linux eMail Server 3.0) with ESMTP id 3012C21B2D1
	for <nfs@lists.sourceforge.net>; Fri, 10 Sep 2004 14:00:22 +0800 (PHT)
To: nfs@lists.sourceforge.net
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

i'm having problems opening my nfs mounted files on the client machine.
Mounting the nfs share on the client goes ok. the user and group
permissions are ok. i could even ls -l and cd into the mounted directory
and subdirectories but when i open a file (cat somefile.txt) i get a
segmentation fault. after that, umounting the nfs share seems to hang.

i noticed this problem when i upgraded the kernel on the client machine
from 2.4 to 2.6. (is there any relation?)

server config:				client config:
nfs-utils version 1.0.1			nfs-utils version 1.0.1
kernel ver. 2.4.18-14			kernel ver. 2.6.8
redhat 8.0 distro			fedora core 1.0

/etc/exports = "/data/revr	192.168.168.1(ro,sync)"
rpcinfo -p localhost on the server:
-bash-2.05b$ /usr/sbin/rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    856  rquotad
    100011    2   udp    856  rquotad
    100011    1   tcp    859  rquotad
    100011    2   tcp    859  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100005    1   udp  32776  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32776  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32776  mountd
    100005    3   tcp  32770  mountd
rpcinfo -p servername run on the client:
[revr@roach revr]$ /usr/sbin/rpcinfo -p 192.168.168.254
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    856  rquotad
    100011    2   udp    856  rquotad
    100011    1   tcp    859  rquotad
    100011    2   tcp    859  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100005    1   udp  32776  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32776  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32776  mountd
    100005    3   tcp  32770  mountd

the nfs-utils on the client was originally 1.0.6. i tried installing
nfs-utils 1.0.1 but still the same error message. i hope this
information is enough to solve my nfs problem. tia



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
