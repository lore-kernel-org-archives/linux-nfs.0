From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: [NFS] access gives ENOENT on existing file
Date: Thu, 29 Nov 2007 20:20:35 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711292001110.32427@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-957264973-1196364035=:32427"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxowB-0007fa-FN
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:20:40 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxowG-0007I3-90
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:20:45 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 6DC215F0413
	for <nfs@lists.sourceforge.net>; Thu, 29 Nov 2007 20:20:35 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-957264973-1196364035=:32427
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE


Either I'm just to tired to see whats wrong, or I'm looking at a strange=20
bug. The system is Fedora 8 with kernel 2.6.23.1-49.fc8. The F8 update=20
repository is NFS mounted as /import/mirrors/fedora/updates/8/i386/.=20

# repoview /import/mirrors/fedora/updates/8/i386/
Not found: /import/mirrors/fedora/updates/8/i386/repodata/repomd.xml
Does not look like a repository. Exiting.

Running strace shows:

access("/import/mirrors/fedora/updates/8/i386/repodata/repomd.xml", R_OK) =
=3D -1 ENOENT (No such file or directory)

The file *is* accessible:

# md5sum /import/mirrors/fedora/updates/8/i386/repodata/repomd.xml
529b7a4d4e745da3053f41ef2a38d1a5  /import/mirrors/fedora/updates/8/i386/rep=
odata/repomd.xml

With my own "access" command, the access system call also succeeds:

access("/import/mirrors/fedora/updates/8/i386/repodata/repomd.xml", R_OK) =
=3D 0

Also, on another machine running Fedora 7, repoview works correctly,=20
against the same NFS server.=20

Any ideas?

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-957264973-1196364035=:32427
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
--789237761-957264973-1196364035=:32427
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--789237761-957264973-1196364035=:32427--


