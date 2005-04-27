From: esqueleto@tusofona.com
Subject: Mount / Umount NFS mount points (Part II)
Date: Wed, 27 Apr 2005 12:55:08 +0100
Message-ID: <1114602908.426f7d9c83848@webmail.tusofona.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQl8Q-0001DC-K4
	for nfs@lists.sourceforge.net; Wed, 27 Apr 2005 04:55:18 -0700
Received: from [81.92.210.10] (helo=agata.100limite.pt)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQl8L-00016n-NP
	for nfs@lists.sourceforge.net; Wed, 27 Apr 2005 04:55:18 -0700
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

Hello

I've found new things about mount and umount NFS mount points over Wirele=
ss /
Wired network.

Now i'm mounting my NFS, not with defaults, but with hard,intr options an=
d i can
disconnect my Wireless and reconnect and the system mount the NFS ok.

When i change from wireless to wired (or otherwise) the problem continues=
. The
NFS cannot mount the NFS mount points. When i came back to wireless i can=
 get
the mount points again.

I think that, the NFS with the hard,intr option can mount using a specifi=
c ethx.
When we change it, the NFS get confused.

This is a real problem. If the NFS can continue to mount over diferents e=
thx the
Wireless / wired problem desappears.

hope this help.


tkx in advance
(())
Esqueleto
Odivelas - Portugal

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.



-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=3D105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
