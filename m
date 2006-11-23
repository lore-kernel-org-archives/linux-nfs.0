From: Peter Astrand <astrand@cendio.se>
Subject: Re: unfsd strange behaviour ?
Date: Thu, 23 Nov 2006 13:35:32 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611231330340.3308@maggie.lkpg.cendio.se>
References: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
	<Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
	<9c8209a10611220835h40af88fdpdb4c36327e674235@mail.gmail.com>
	<Pine.LNX.4.64.0611221804480.28977@maggie.lkpg.cendio.se>
	<9c8209a10611221042v6d669d3tbabf405022f0efcb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1342355276-1164285332=:3308"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GnDno-0007JZ-MU
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 04:35:40 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GnDno-00076y-Nv
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 04:35:42 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611221042v6d669d3tbabf405022f0efcb@mail.gmail.com>
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

--789237761-1342355276-1164285332=:3308
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Nov 2006, Murali Bashyam wrote:

> > If you turn off the file handle cache, the number of stat()s will
> > increase.
>=20
> So while performing the stat call, it has to map the file handle which =
came
> in the GETATTR NFS request to a file name, correct?=20

Yes.=20


> My question was whether it is possible that the mapping can become=20
> stale, if that mapping is cached.

No, I don't think so. From looking at the source code, it seems like unfs=
3=20
does a stat() to verify that the file still has the correct st_dev and=20
st_ino, even when the file handle cache is used.


Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--789237761-1342355276-1164285332=:3308
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1342355276-1164285332=:3308
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1342355276-1164285332=:3308--
