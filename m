From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Slow performance with 2.4.19pre1
Date: Thu, 4 Jul 2002 12:24:49 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207021355580.22749-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from plum.csi.cam.ac.uk ([131.111.8.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Q4jJ-00066s-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 04:24:57 -0700
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by plum.csi.cam.ac.uk with esmtp (Exim 4.05)
	id 17Q4jB-0004Jp-00
	for nfs@lists.sourceforge.net; Thu, 04 Jul 2002 12:24:49 +0100
Received: from xalph6.ast.cam.ac.uk (xalph6 [131.111.68.34])
	by cass41.ast.cam.ac.uk (8.11.6+Sun/8.11.6) with ESMTP id g64BOn201152
	for <nfs@lists.sourceforge.net>; Thu, 4 Jul 2002 12:24:49 +0100 (BST)
Received: from xpc1.ast.cam.ac.uk (IDENT:D+HXpQOjOj51Gsard6gxbFJ6XF/Zv/oT@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xalph6.ast.cam.ac.uk (8.10.0/8.10.0) with ESMTP id g64BOnp03062
	for <nfs@lists.sourceforge.net>; Thu, 4 Jul 2002 12:24:49 +0100 (BST)
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

Using a 2.4.19pre1 on the server (ext3 & raid1 on an IDE disk) I'm getting
very poor read and rewrite performance using nfs. There's no difference
using RedHat's 2.4.18-5 kernel on the server. The client is running
RedHat's 2.4.18-5 kernel.  Here are the results from running bonnie++:

Version 1.02a       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
xpc1.ast.cam.ac. 1G  9242  52  9452   7   644   0  1624   8  1731   1 488.7   3
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  1207   3   182  96  2157   7  1224   3  4521   5  1766   4
xpc1.ast.cam.ac.uk,1G,9242,52,9452,7,644,0,1624,8,1731,1,488.7,3,16,1207,3,182,96,2157,7,1224,3,4521,5,1766,4

The machine is connected over 100Mps ethernet, full duplex. The mount
options are below:

xpc1:/<1>nfs/test> cat /proc/mounts
[...]
xserv1.ast.cam.ac.uk:/mnt/raid /mnt/nfs nfs
rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=xserv1.ast.cam.ac.uk 0 0

Local performance is very good (note different file size):

Version 1.02a       ------Sequential Output------ --Sequential Input----Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
xserv1.ast.cam.a 2G 22311  96 40600  13 16150   4 24853  96 45830   5 323.0   0
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
                 16  2715  98 +++++ +++ +++++ +++  2784  98 +++++ +++  8798  99
xserv1.ast.cam.ac.uk,2G,22311,96,40600,13,16150,4,24853,96,45830,5,323.0,0,16,2715,98,+++++,+++,+++++,+++,2784,98,+++++,+++,8798,99

The network card and duplex/speed settings look okay (eepro100):

[root@xserv1 raid]# /root/mii-diag
Using the default interface 'eth0'.
Basic registers of MII PHY #1:  3000 782d 02a8 0154 05e1 45e1 0003 0000.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x3000: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver information.

However, if the client runs 2.4.17 instead of
2.4.18/2.4.19rc1/2.4.18-redhat then the read speed is much better:

Version 1.02a       ------Sequential Output------ --Sequential Input- --Random-
                    -Per Chr- --Block-- -Rewrite- -Per Chr- --Block-- --Seeks--
Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
xpc17.ast.cam.ac 1G 11255  74 10539   5  5239   4 11336  78 11260   3 575.6   3
                    ------Sequential Create------ --------Random Create--------
                    -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
              files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP /sec %CP
                 16  1179   3  4176  14  2318   8  1230   4  4504  12  1755   6
xpc17.ast.cam.ac.uk,1G,11255,74,10539,5,5239,4,11336,78,11260,3,575.6,3,16,1179,3,4176,14,2318,8,1230,4,4504,12,1755,6
(same mount options as above)

Any ideas what problem there is in the 2.4.18+ nfs client? Is this a
networking thing showing up under 2.4.18?

This looks like RedHat's bug 67625.

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053











-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
