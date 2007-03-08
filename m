From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: nfs-utils, e_maptype
Date: Thu, 8 Mar 2007 14:28:17 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0703081426170.25244@maggie.lkpg.cendio.se>
References: <20070307022107.GC27862@fieldses.org>
	<200703072123.47224.okir@lst.de>
	<20070307212844.GQ26553@fieldses.org> <200703080949.54293.okir@lst.de>
	<EXNANE01Ogl4rhYQYx30000007d@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1601168487-1173360497=:25244"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPIfQ-0001Zc-4a
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:28:24 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPIfP-0004xY-UX
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 05:28:26 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 44F9125DA34
	for <nfs@lists.sourceforge.net>; Thu,  8 Mar 2007 14:28:17 +0100 (CET)
In-Reply-To: <EXNANE01Ogl4rhYQYx30000007d@exnane01.hq.netapp.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1601168487-1173360497=:25244
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 8 Mar 2007, Talpey, Thomas wrote:

> At 03:49 AM 3/8/2007, Olaf Kirch wrote:
> >I think it's safe to ignore unfsd.
>=20
> I agree, but I've been surprised to see some of the embedded (ARM) ports
> using it, they have .deb-style package installs and everything. Many of t=
he
> users of these packages don't have a lot of NFS depth. The tiny NAS boxes
> in general don't even enable NFS by default, the users are on their own a=
nd
> unfsd means they don't have to muck with the embedded kernel.
>=20
> That said, I don't think these users even know about userid mapping types=
=2E
> Also most of the boxes are now doing what they call knfsd. Just a data po=
int
> that unfsd isn't totally dead.

Users of the "original" unfsd could then switch to unfs3, which doesn't=20
depend on e_maptype.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1601168487-1173360497=:25244
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1601168487-1173360497=:25244
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1601168487-1173360497=:25244--
