From: Brad Barnett <lists@l8r.net>
Subject: root NFS causes solid lockup, serial console no help,
 watchdog NMI won't function on Dual AMD system
Date: Tue, 14 Nov 2006 06:38:00 -0500
Message-ID: <20061114063800.42bb402b@be.back.l8r.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjwcA-0007IE-T6
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 03:38:07 -0800
Received: from l8r.net ([206.248.172.29] ident=aliens)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjwcA-000117-PA
	for nfs@lists.sourceforge.net; Tue, 14 Nov 2006 03:38:08 -0800
Received: from be.back.l8r.net (bbarnett@be [10.10.10.10])
	by l8r.net (8.13.4/8.13.4/Debian-3sarge1) with ESMTP id kAEBc0rX001732
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Tue, 14 Nov 2006 06:38:01 -0500
To: NFS List <nfs@lists.sourceforge.net>
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



Hello,

I have a couple of dual AMD Opteron system with differing motherboards. 
On both of these differing pieces of hardware, I can not enable the NMI
watchdog timer, with nmi_watchdog=1.  I constantly get:

testing NMI watchdog ... CPU#0: NMI appears to be stuck (0->0)!

This happens when booting with both Debian's packaged kernels, 2.6.17-2
and 2.6.18-2.  According to this page:

http://www.mjmwired.net/kernel/Documentation/nmi_watchdog.txt

nmi_watchdog=2 does not work with AMD systems at this time.

Both boxes, aside from this, boot fine.  They use nfsroot, booting the
kernel off of a local drive, and switching to nfsroot during the bootup. 
They work flawlessly for anywhere from a week to a few days, then lock up
solid.  I can not seem to reproduce this problem unless I am using
nfsroot, and the above kernels seem fine without issue when booting and
running off of a local drive.

I can not get any information from a serial console, and just for fun I
redirected syslog to another box, yet I did not see anything about the
impending doom to come.  The console itself is simply a blank screen, and
the keyboard is dead... 

Does anyone have any suggestions for tracking this bug down?

Thanks


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
