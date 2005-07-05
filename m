From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Linux client with MS SFU server
Date: Tue, 5 Jul 2005 18:47:52 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-264266249-1120582072=:28175"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dpqad-0007KI-QB
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 09:48:07 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Dpqaa-0004Bz-FM
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 09:48:07 -0700
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id A20DF25DB1F
	for <nfs@lists.sourceforge.net>; Tue,  5 Jul 2005 18:47:52 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-264266249-1120582072=:28175
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable


I'm trying to use the Linux NFS client with a Microsoft "Services For=20
UNIX" (SFU) server. The SFU version if 2.2. The server is actually a HP=20
Storageworks 1000s NAS server.

It's possible to mount, but then I'm stuck. Basically every operation on=20
/mnt, except ls/stat on the mount point itself, gives me "permission=20
denied". The permissions on /mnt is 050, so I'm not surprised I cannot=20
enter the directory. What's strange, though, is that "chown", "chmod" etc=
=20
also fails, even though I'm root, and the server does not use root=20
squashing.

I've captured a few packets with Ethereal. What's surprises me is that th=
e=20
server is returning RPC-level AUTH_ERRORs. Is this really normal?

I've tried both UDP and TCP, and both v2 and v3. The packet capture is=20
available as http://www.cendio.se/~peter/tmp/sfu22-auth-error.cap.

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-264266249-1120582072=:28175--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
