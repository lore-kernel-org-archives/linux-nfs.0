From: Peter Astrand <astrand@cendio.se>
Subject: Re: Improving unfsd scalability: TI-RPC
Date: Fri, 1 Dec 2006 14:52:26 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612011448540.29202@maggie.lkpg.cendio.se>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
	<20061130181308.GA12747@suse.de>
	<Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
	<20061130200110.GA26145@suse.de>
	<1164973277.23144.81.camel@frecb000687.frec.bull.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1174584289-1164981026=:29202"
Cc: cyril.lacabanne@ema.fr, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq8ob-0003qc-Hh
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 05:52:33 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gq8ob-0004xq-3h
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 05:52:34 -0800
To: Tony Reix <tony.reix@bull.net>
In-Reply-To: <1164973277.23144.81.camel@frecb000687.frec.bull.fr>
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

--789237761-1174584289-1164981026=:29202
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-ID: <Pine.LNX.4.64.0612011450281.29202@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Fri, 1 Dec 2006, Tony Reix wrote:

> > > instead? TI-RPC? It has thread support, but it's also much more=20
> > > complicated. The implementation is not as tested and the libtirpc=20
> > > implementation is not based on the latest Sun release. And, libtirp=
c has=20
> > > not been ported to Windows yet, and the thread stuff makes porting=20
> > > somewhat difficult.=20
> >=20
> > I'm not a huge fan of TIRPC either.
>=20
> Hi Olaf, Peter,
>=20
> We'll have a student, Cyril, in 2007 during 5 months about TI-RPC.
> His main goal deals with writing tests for RPC and TI-RPC lib.
> But any ideas are welcome to improve TI-RPC and make you a fan of it !
> Do you have a list of complaints about TI-RPC ?

This sounds great. Have you decided on the test framework and/or language=
=20
yet? pynfs might be useful... :-)

To all: I've created a Sourceforge project for libtirpc. No source code=20
has been imported yet, but I will fix this in a near future.=20

Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--789237761-1174584289-1164981026=:29202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1174584289-1164981026=:29202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1174584289-1164981026=:29202--
