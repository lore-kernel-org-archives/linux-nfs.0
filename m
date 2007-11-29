From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: [NFS] access gives ENOENT on existing file
Date: Thu, 29 Nov 2007 20:39:04 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711292038300.473@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.64.0711292001110.32427@maggie.lkpg.cendio.se>
	<1196364589.7808.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1277855456-1196365144=:473"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpE3-0001Gv-NW
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:39:07 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpE8-0006pz-2k
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:39:13 -0800
In-Reply-To: <1196364589.7808.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1277855456-1196365144=:473
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 29 Nov 2007, Trond Myklebust wrote:


> > With my own "access" command, the access system call also succeeds:
> >=20
> > access("/import/mirrors/fedora/updates/8/i386/repodata/repomd.xml", R_O=
K) =3D 0
> >=20
> > Also, on another machine running Fedora 7, repoview works correctly,=20
> > against the same NFS server.=20
> >=20
> > Any ideas?
>=20
> tcpdump?

http://www.cendio.com/~astrand/nfs1/repoview.cap


Best regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1277855456-1196365144=:473
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
--789237761-1277855456-1196365144=:473
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

--789237761-1277855456-1196365144=:473--


