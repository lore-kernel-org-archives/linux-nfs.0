From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re:
 =?iso-8859-15?q?kernel+userspace_based_nfsd_running_in_para?=
 =?iso-8859-15?q?llel__on_linux=3F?=
Date: Sat, 16 Dec 2006 22:01:43 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612162156180.30063@maggie.lkpg.cendio.se>
References: <1499275894@web.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-2037102972-1166302903=:30063"
Cc: Bernd Schubert <bernd-schubert@gmx.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvgfH-0005mT-Gj
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:01:51 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GvgfH-0003OF-Lv
	for nfs@lists.sourceforge.net; Sat, 16 Dec 2006 13:01:53 -0800
To: devzero@web.de
In-Reply-To: <1499275894@web.de>
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

--789237761-2037102972-1166302903=:30063
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 16 Dec 2006, devzero@web.de wrote:

> > Hmm, I thing this is presently not possible. I might be wrong, but I th=
ink=20
> > neither knfsd nor any userspace nfs daemon presently supports binding t=
o=20
> > selected interfaces. Thinks they alsways bind to all interfaces.
>=20
> i wonder very often, why there are so many applications out there which=
=20
> actually _DON`T_ support this. if you are a security aware person, this=
=20

Actually, unfs3 does support this. Just use the -l argument.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-2037102972-1166302903=:30063
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-2037102972-1166302903=:30063
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-2037102972-1166302903=:30063--
