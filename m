From: "Paul Hobbs" <pjhobbs@dowdingandmills.com>
Subject: Segmentation Fault when trying to mount an NFS Filesystem
Date: Mon, 31 Jul 2006 11:25:44 +0100
Message-ID: <OBEILOALCFKJGICOCIFLKEBOCHAA.pjhobbs@dowdingandmills.com>
Reply-To: pjhobbs@dowdingandmills.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Uwp-0000RE-Hw
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 03:24:31 -0700
Received: from relay1.dowdingandmills.com ([193.123.253.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7Uwo-0003So-D0
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 03:24:32 -0700
To: <nfs@lists.sourceforge.net>
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


Hi,

I've read the NFS-HOWTO and have drawn a blank, please can you help?

I need to share some cert files on another box, however I'm getting a
Segmentation Fault
whenever I attempt to mount the NFS share. This was all working fine for
months until a
change was made to a CNAME on our DNS Server. The CNAME was changed from
pointing to
192.168.99.11 to point at another server 192.168.99.23. Since then it has
not worked, I
can't see how this change could of messed things up on the NFS has I've
always used the
IP addresses.

The other thing that is strange is that it works fine if I mount from
192.168.99.99
to 192.168.99.10, but does not work when mounting to 192.168.99.11. Both
machines
192.168.99.10 and 192.168.99.11 are the same build and configuration.

All machines are connected locally using a Gigabit Switch on the same
network 192.168.99.0.

Can anyone please offer any advice?

Many Thanks

Paul

----------------------------------------------------------------------------
-------------

NFS Server 1 - WORKS FINE (192.168.99.10)

----------------------------------------------------------------------------
-------------

NFS Utils Version    : nfs-utils-0.3.1-68
Kernel Version       : 2.4.18-64GB-SMP
Distribution Version : SuSE Linux Enterprise Server v7


dev:/ # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    840  status
    100024    1   tcp    842  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  33493  nlockmgr
    100021    3   udp  33493  nlockmgr
    100021    4   udp  33493  nlockmgr
    100005    1   udp  33494  mountd
    100005    1   tcp  40182  mountd
    100005    2   udp  33494  mountd
    100005    2   tcp  40182  mountd
    100005    3   udp  33494  mountd
    100005    3   tcp  40182  mountd


dev:~ # cat /etc/exports
/data/www/spooled/certs 192.168.99.99(ro,hide,sync,no_root_squash)


dev:~ # exportfs -rv
exporting 192.168.99.99:/data/www/spooled/certs


dev:~ # cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/data/www/spooled/certs 192.168.99.99(ro,no_root_squash,sync,wdelay) #
192.168.99.99



----------------------------------------------------------------------------
-------------

NFS Server 2 - DOES NOT WORK (192.168.99.11)

----------------------------------------------------------------------------
-------------

NFS Utils Version    : nfs-utils-0.3.1-68
Kernel Version       : 2.4.18-64GB-SMP
Distribution Version : SuSE Linux Enterprise Server v7


was:~ # rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    854  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100024    1   tcp    856  status
    100005    1   udp  33239  mountd
    100005    1   tcp  36855  mountd
    100021    1   udp  33240  nlockmgr
    100005    2   udp  33239  mountd
    100021    3   udp  33240  nlockmgr
    100005    2   tcp  36855  mountd
    100021    4   udp  33240  nlockmgr


was:~ # cat /etc/exports
/data/www/spooled/certs 192.168.99.99(ro,hide,sync,no_root_squash)


was:~ # exportfs -rv
exporting 192.168.99.99:/data/www/spooled/certs


was:~ # cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/data/www/spooled/certs 192.168.99.99(ro,no_root_squash,sync,wdelay) #
192.168.99.99



----------------------------------------------------------------------------
-------------

NFS Client (192.168.99.99)

----------------------------------------------------------------------------
-------------

NFS Utils Version    : nfs-utils-1.0.6-65.EL4
Kernel Version       : 2.6.9-22.0.2.ELsmp
Distribution Version : Red Hat Enterprise Linux ES release 4 (Nahant Update
2)


[root@cis ~]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status


[root@cis ~]# mount -v -t nfs 192.168.99.10:/data/www/spooled/certs
/u/www/certs
192.168.99.10:/data/www/spooled/certs on /u/www/certs type nfs
(rw,addr=192.168.99.10)


[root@cis ~]# mount -v -t nfs 192.168.99.11:/data/www/spooled/certs
/u/www/certs
Segmentation fault



----------------------------------------------------------------------------
-------------

Paul Hobbs
Development Team Leader
Dowding & Mills plc

Telephone : +44 (0)121 766 6161 (x364)
Fax       : +44 (0)121 773 9957
Web       : http://www.dowdingandmills.com

____________________________________________________________
This E-mail message contains proprietary information
that is intended only for the named recipient (s) some or
all of which may be legally privileged or confidential.
If you are not the intended recipient you must not use,
disclose, distribute, copy, print or rely in any way on the
content of this E-mail message. Dowding & Mills plc is not
responsible for any personal opinions expressed in E-mails.
While every effort has been made to ensure the attachments
are virus-free, they must be checked before use, especially
those containing encrypted data. Please notify the author of
this E-mail message if you are not the intended recipient or
if you have any other problems with this e-mail at the above
e-mail address.

Dowding & Mills plc Registered in England 160837



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
