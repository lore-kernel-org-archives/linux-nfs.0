From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] Remove "maptype" support
Date: Tue, 13 Mar 2007 18:24:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0703131819560.17686@maggie.lkpg.cendio.se>
References: <20070307022107.GC27862@fieldses.org>
	<17910.13751.310917.35119@notabene.brown>
	<20070313170505.GA15964@fieldses.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-227701459-1173806665=:17686"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRAjh-0007WM-L2
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:24:35 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRAji-0004QW-CG
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:24:35 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id CB91325DA34
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 18:24:25 +0100 (CET)
In-Reply-To: <20070313170505.GA15964@fieldses.org>
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

--789237761-227701459-1173806665=:17686
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 13 Mar 2007, J. Bruce Fields wrote:

> It appears that this is used only by unfsd, and is obscure enough that
> we should be able to just rip it out with no special precautions.

Btw, I checked the source of nfs-server-2.2beta47, which is available from=
=20
http://sourceforge.net/project/showfiles.php?group_id=3D5768, and I can't=
=20
find any references to "maptype" in this source either.=20

As far as I know, nfs-server-2.2beta47 is the latest version of the old=20
unfsd code.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-227701459-1173806665=:17686
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-227701459-1173806665=:17686
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-227701459-1173806665=:17686--
