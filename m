From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Random ESTALE due to lookup "/" in mount point?
Date: Wed, 23 Aug 2006 17:09:41 +0200
Message-ID: <20060823150941.GA13000@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GFuMZ-0003yO-Vi
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 08:09:52 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GFuMZ-0006Ip-5T
	for nfs@lists.sourceforge.net; Wed, 23 Aug 2006 08:09:52 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

NFSv3, udp, client=2.6.17.8, server=tru64

On the client I started to get some random ESTALE errors which disappeared
quickly afterwards without a remount. The errors only occurred when typing

	stat ..

in a subdirectory of a mountpoint. Doing ls -al in that subdirectory
gave an ESTALE only on "..". I could even change directory to / and back
without an ESTALE but the "stat .." command still gave an ESTALE.

A "tcpdump -i eth0 udp port 2049 -n -s 1500" showed something which is
unusual to my knowledge. The kernel tried to lookup "/" in the mount
point as it seems:

   16:42:03.644621 IP 172.17.1.64.3759242568 > 172.17.1.1.2049: 120 lookup fh 2956,259248/28524 "stat"
   16:42:03.644967 IP 172.17.1.1.2049 > 172.17.1.64.3759242568: reply ok 116 lookup ERROR: No such file or directory
   16:42:03.647345 IP 172.17.1.64.3776019784 > 172.17.1.1.2049: 112 getattr fh 2956,259248/2
   16:42:03.647496 IP 172.17.1.1.2049 > 172.17.1.64.3776019784: reply ok 112 getattr DIR 1777 ids 0/0 sz 0x2000
=> 16:42:03.648002 IP 172.17.1.64.3792797000 > 172.17.1.1.2049: 120 lookup fh 2956,259248/2 "/"
   16:42:03.648244 IP 172.17.1.1.2049 > 172.17.1.64.3792797000: reply ok 116 lookup ERROR: No such file or directory
   16:42:03.648440 IP 172.17.1.64.3809574216 > 172.17.1.1.2049: 112 getattr fh 2956,259248/2
   16:42:03.648680 IP 172.17.1.1.2049 > 172.17.1.64.3809574216: reply ok 112 getattr DIR 1777 ids 0/0 sz 0x2000
=> 16:42:03.648877 IP 172.17.1.64.3826351432 > 172.17.1.1.2049: 120 lookup fh 2956,259248/2 "/"
   16:42:03.649110 IP 172.17.1.1.2049 > 172.17.1.64.3826351432: reply ok 116 lookup ERROR: No such file or directory
   16:42:09.605452 IP 172.17.1.64.3879531864 > 172.17.1.1.2049: 116 access fh 3806,805074/16337 001f
   16:42:09.605758 IP 172.17.1.1.2049 > 172.17.1.64.3879531864: reply ok 120 access c 001f

-- 
Frank

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
