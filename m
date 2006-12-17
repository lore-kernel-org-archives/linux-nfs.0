From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: kernel+userspace based nfsd running in parallel on linux?
Date: Sun, 17 Dec 2006 11:25:45 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612170140250.31965@maggie.lkpg.cendio.se>
References: <1499049521@web.de> <200612161717.31090.bernd-schubert@gmx.de>
	<20061216215544.GA5968@suse.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-632541144-1166316134=:31965"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GvtDO-0005Lt-Mi
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 02:25:54 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GvtDM-00069U-L5
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 02:25:56 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id C63EB25DB24
	for <nfs@lists.sourceforge.net>; Sun, 17 Dec 2006 11:25:45 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061216215544.GA5968@suse.de>
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

--789237761-632541144-1166316134=:31965
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0612171100551.26028@maggie.lkpg.cendio.se>

On Sat, 16 Dec 2006, Olaf Kirch wrote:

> > to tell one of the daemon not to register to the portmapper, unfs3 also=
=20
> > supports that.
>=20
> The big problem will be mountd. There's only one portmapper, and you
> can register only one mountd - and the file handles given out by unfs
> mountd don't work with the kernel nfsd and vice versa.

This is no problem, you can run both the nfs and mount service without the=
=20
portmapper. They can even run on the same port. So, typically you run=20
unfs3 with:

unfsd -n 4711 -m 4711 -p

=2E..and then mount with:

mount -t nfs -o mountvers=3D3,mountport=3D4711,nfsvers=3D3,port=3D4711,tcp =
server:/path /local/path

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-632541144-1166316134=:31965
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-632541144-1166316134=:31965
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-632541144-1166316134=:31965--
