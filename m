From: "J.Rinas" <jrinas@gmx.de>
Subject: invalidate cache / NFS performance on a diskless system
Date: Thu, 9 Dec 2004 17:18:48 +0100
Message-ID: <200412091718.48973.jrinas@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcdJX-0004uQ-T0
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 21:27:35 -0800
Received: from mail0.ewetel.de ([212.6.122.10])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcdJV-00041O-RT
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 21:27:35 -0800
Received: from jrdesk.example.com (dialin-80-228-48-015.ewe-ip-backbone.de [80.228.48.15])
	by mail0.ewetel.de (8.12.1/8.12.9) with ESMTP id iB9GIme7028116
	for <nfs@lists.sourceforge.net>; Thu, 9 Dec 2004 17:18:48 +0100 (MET)
Received: from [127.0.0.1] (helo=localhost)
	by jrdesk.example.com with esmtp (Exim 4.34)
	id 1CcR0D-0002ma-CS
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 17:18:49 +0100
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

Hello!

We've set up our network using a linux 2.6.9 server and
abt. 25-30 linux clients using NFS.
The clients are booting through PXE and work in a diskless fashion.
i.e.=20
they mount their root directory via NFS
only /var and /tmp are on a tmpfs device.


To improve performance we have currently set the root directory=20
(including the /usr tree) to use the mount options

  ro,
  noatime,
  v3,
  rsize=3D32768,wsize=3D32768,
  actimeo=3D180,
  hard,tcp,nocto,nolock


To further improve the performance of the clients,=20
I'd like to increase  actimeo to abt. 9 hours.
But this leads to severe problems, if some small configurations are done=20
during the day (e.g. installing new soft or configuration work...):
The changes do not apprear on the client nodes in reasonable time.

So I'd like to know if there is a switch to invalidate the whole NFS / VFS?=
=20
cache at once!
(e.g. an    echo something > /proc/somewhere  )?

An there any other hints/experiences to improve performance on such a syste=
m?
(Our new server with 10k rpm Disks is already ordered!)

tnx fr ur help
  J=FCrgen


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
