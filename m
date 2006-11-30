From: Peter Astrand <astrand@cendio.se>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 19:27:15 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611301919430.25539@maggie.lkpg.cendio.se>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
	<20061130102238.GA11918@suse.de>
	<9c8209a10611300958q7fd8bcb8u1001cc936062308b@mail.gmail.com>
	<20061130181308.GA12747@suse.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1876775880-1164911235=:25539"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gpqd8-0000UJ-JI
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:27:30 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gpqd4-0000fz-HH
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 10:27:29 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id D653425DA34
	for <nfs@lists.sourceforge.net>; Thu, 30 Nov 2006 19:27:15 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061130181308.GA12747@suse.de>
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

--789237761-1876775880-1164911235=:25539
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 30 Nov 2006, Olaf Kirch wrote:

> Anything multithreaded would require writing your own librpc.
> There's no way you can make the current RPC code reasonably
> efficient wrt multithreading.
>=20
> I just wish people would leave this old code to Rot In Peace :)

Yes, the old ONC RPC code is far from optimal. But, what do you suggest=20
instead? TI-RPC? It has thread support, but it's also much more=20
complicated. The implementation is not as tested and the libtirpc=20
implementation is not based on the latest Sun release. And, libtirpc has=20
not been ported to Windows yet, and the thread stuff makes porting=20
somewhat difficult.=20

Btw, I'm also not convinced that threading is the best solution. I tend t=
o=20
like multi-process or select-based solutions better.

Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--789237761-1876775880-1164911235=:25539
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1876775880-1164911235=:25539
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1876775880-1164911235=:25539--
