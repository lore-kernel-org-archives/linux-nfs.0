From: Peter Astrand <astrand@cendio.se>
Subject: Re: unfsd strange behaviour ?
Date: Wed, 22 Nov 2006 18:10:37 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611221804480.28977@maggie.lkpg.cendio.se>
References: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
	<Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
	<9c8209a10611220835h40af88fdpdb4c36327e674235@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1988547174-1164215400=:28977"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmvcV-0003Om-5W
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 09:10:47 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmvcU-0007f4-Vs
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 09:10:48 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611220835h40af88fdpdb4c36327e674235@mail.gmail.com>
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

--789237761-1988547174-1164215400=:28977
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-ID: <Pine.LNX.4.64.0611221810331.28977@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable


> It's not a LOOKUP operation in the NFS sense, actually the FUSE module =
that
> is handling the operation reports it as a lookup (the unfsd backend cal=
l
> ends up being handled by a FUSE server that i am developing). What actu=
ally
> happens on the FUSE side is a operation (called getattr, not to be conf=
used
> with the NFS getattr) with a path name and the path name happens to be =
a
> altogether different file name.=20

The FUSE getattr is probably the result of unfsd doing a normal stat().=20
This is expected: When unfsd is "decomposing" a file handle into a path,=20
it stat:s every file in the target directory (actually, plausible=20
directories), until it finds a file with the correct st_dev and st_ino.=20


> I noticed in the unfsd code that the unfsd is maintaining a file handle=
=20
> cache, and also issues backend operations based on the path name in tha=
t=20
> cache, could there be a stale entry in that cache? Is there a way to=20
> turn off this file handle caching in unfsd? At this point i am not sure=
=20
> whether FUSE may be causing this behaviour or not.

If you turn off the file handle cache, the number of stat()s will=20
increase.=20

Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--789237761-1988547174-1164215400=:28977
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-1988547174-1164215400=:28977
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1988547174-1164215400=:28977--
