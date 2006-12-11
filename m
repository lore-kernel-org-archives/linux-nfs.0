From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Large FSINFO3resok.rtmax, UDP and stuff
Date: Mon, 11 Dec 2006 22:21:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0612111105270.31602@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-448581232-1165831643=:31602"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gtsaa-0001WJ-Tc
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 13:21:33 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gtsaa-0006YO-SG
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 13:21:34 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 63FAE25DA34
	for <nfs@lists.sourceforge.net>; Mon, 11 Dec 2006 22:21:23 +0100 (CET)
To: nfs@lists.sourceforge.net
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

--789237761-448581232-1165831643=:31602
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0612112156031.3573@maggie.lkpg.cendio.se>


I'd like to configure my (unfs3) server to support large read and write=20
sizes, to get good speed on high latency links. The plan is to increase=20
FSINFO3resok.{rtmax,wtmax} to something very large, like 256KB, and then=20
mount with the same rsize/wsize. Will this work with various versions of=20
the kernel, or can I expect problems?=20

Another question is how UDP should be handled. Although I will mostly use=
=20
TCP, I'd still like the server to be functional for UDP. Since UDP is=20
limited to 65K, I need some special handling. Which one is best?:

1) Have FSINFO return the same large (256KB) rtmax/wtmax, even when called=
=20
   via UDP. In practice, I guess clients won't ask for a READ with=20
   count=3D256K or count=3D65535, but what if they do? As far as I understa=
nd,=20
   the server is not allowed to return a short read if count is less than=
=20
   rtmax.

or

2) Have FSINFO return something smaller when called via UDP. It's a little=
=20
   bit strange that FSINFO returns different values depending on if you=20
   call it over TCP or UDP, but it does solve the problem above.


Also, I'm a bit unsure of which packet sizes I should specify to=20
svcudp_bufcreate(), to get the largest possible UDP RPC packets. Can I=20
specify 65535, or should I compensate for the RPC header size?

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-448581232-1165831643=:31602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-448581232-1165831643=:31602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-448581232-1165831643=:31602--
