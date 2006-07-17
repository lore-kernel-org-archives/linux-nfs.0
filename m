From: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
Subject: NFS export/mount problem ERR_ACCESS for exported mount point
Date: Mon, 17 Jul 2006 14:31:27 +0200
Message-ID: <44BB9F3D.14211.1695037@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@cse.unsw.edu.au
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2SGi-00014z-Ck
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 05:32:12 -0700
Received: from rrzmta2.rz.uni-regensburg.de ([132.199.1.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2SGi-0005IM-8y
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 05:32:12 -0700
To: nfs@lists.sourceforge.net
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

I have a problem with Linux (2.6.5-7.267-smp) not letting me mount a filesystem 
via NFS that I have exported. The exported path is a mount point where some CIFS 
filesystem is mounted.

Reasoning:
A specific CIFS filesystem (Windows/2003 Server) is needed on a bunch of servers, 
so I'd prefer mounting CIFS only once on a dedicated host (linux), and from there 
export it via NFS to the remaining clients (which are HP-UX with a poor CIFS 
client).

Unfortunately it doesn't work. Ethereal reveals:
Portmap V2 GETPORT Call MOUNT(100005) V:2 UDP
Portmap V2 GETPORT Reply Port:700
MOUNT V2 NULL Call
MOUNT V2 NULL Reply
MOUNT V2 MNT Call /home/hyperspace/rkapoka1
MOUNT V2 MNT Reply Error:ERR_ACCESS

User Datagram Protocol, Src Port: epp (700), Dst Port: syslog-conn (601)
Remote Procedure Call, Type:Reply XID:0x44bb2150
Mount Service
Program Version: 2
V2 Procedure: MNT (1)
Status: ERR_ACCESS (13)
0000 00 30 6e 48 14 8d 00 0f 1f f9 4c d3 08 00 45 00 .0nH......L...E.
0010 00 38 00 00 40 00 40 11 d1 03 84 c7 b0 12 84 c7 .8..@.@.........
0020 b0 10 02 bc 02 59 00 24 69 e7 44 bb 21 50 00 00 .....Y.$i.D.!P..
0030 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0040 00 00 00 00 00 0d ......

I've heard rumour about some "--re-export" option, but that's not available in my 
version of Linux. Any useful hints, tips, workarounds?

Regards,
Ulrich



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
