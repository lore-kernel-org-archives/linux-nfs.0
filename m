From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re:
 =?iso-8859-15?q?kernel+userspace_based_nfsd_running_in_para?=
 =?iso-8859-15?q?llel_on_linux=3F?=
Date: Mon, 18 Dec 2006 09:32:35 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612180928001.4577@maggie.lkpg.cendio.se>
References: <1499627837@web.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-500360933-1166430755=:4577"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwDvQ-0003zG-8z
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 00:32:44 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwDvQ-0000I9-Gw
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 00:32:45 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id BC05625DB24
	for <nfs@lists.sourceforge.net>; Mon, 18 Dec 2006 09:32:35 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <1499627837@web.de>
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

--789237761-500360933-1166430755=:4577
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 16 Dec 2006, devzero@web.de wrote:

> >Oh, and what about locking? :)
>=20
> good point - but not an issue here, because i only need to export read-on=
ly.

Would it at all be possible to support NLM in a userspace NFS server?=20

In either case, I guess it won't work for us, since we are using SSH=20
tunnels...

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-500360933-1166430755=:4577
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-500360933-1166430755=:4577
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-500360933-1166430755=:4577--
