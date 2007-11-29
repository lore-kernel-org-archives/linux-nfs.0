From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Subject: Re: [NFS] access gives ENOENT on existing file
Date: Thu, 29 Nov 2007 21:13:49 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711292104130.956@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.64.0711292001110.32427@maggie.lkpg.cendio.se>
	<1196364589.7808.28.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0711292038300.473@maggie.lkpg.cendio.se>
	<1196365811.19682.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-839436394-1196366676=:956"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ixpli-0004wX-Fl
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 12:13:56 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ixpll-0003oG-A0
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 12:13:59 -0800
In-Reply-To: <1196365811.19682.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-839436394-1196366676=:956
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0711292105501.956-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>

On Thu, 29 Nov 2007, Trond Myklebust wrote:

> > http://www.cendio.com/~astrand/nfs1/repoview.cap
> >=20
>=20
> According to that, the NFS client appears to be looking up the directory
> 'i386\315\204', which does not exist.

Oh.=20

> Can you check again in the 'strace' output whether or not the access()
> syscall is being called with the correct pathname? I suspect a locale
> error or something like that...

You are correct, there's some garbage in the path. After unsetting LANG,=20
the problem remains, but "less" now views:

access("/import/mirrors/fedora/updates/8/i386<CD><84>/repodata/repomd.xml",=
 R_OK) =3D -1 ENOENT (No such file or directory)

I think I've found the problem. Somehow, the incorrect path managed to get=
=20
into my Bash history. I also tried copy-paste from the strace log (which=20
was also "infected"). Gosh.=20


Thanks for the help,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-839436394-1196366676=:956
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
--789237761-839436394-1196366676=:956
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

--789237761-839436394-1196366676=:956--


