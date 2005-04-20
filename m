From: esqueleto@tusofona.com
Subject: Detectiong Network and umount / mount NFS
Date: Wed, 20 Apr 2005 21:02:59 +0100
Message-ID: <1114027379.4266b57354785@webmail.tusofona.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOLPa-0004WZ-KI
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:03:02 -0700
Received: from [81.92.210.10] (helo=agata.100limite.pt)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOLPZ-0005Hu-Ob
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 13:03:02 -0700
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

I'm new at NFS malling list and hope this problem was not inserted before=
.

I have a portable computer with FC3. This computer have Wireless and Wire=
d
network and i have some NFS mount points in my file system.

Usualy i want to change throught between the wireless and wired connectio=
n and
when i do this my mount points became busy.

Ex:
$ sudo umount /home/Acropole/
umount: /home/Acropole: device is busy
umount: /home/Acropole: device is busy

There is some way to umount NFS mount points after the system loose the n=
etwork?

tkx in advance
Esqueleto
Odivelas - Portugal



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

----- End forwarded message -----




----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
