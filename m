From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: Linux NFS client against Auspex server crashes
Date: Thu, 23 Jan 2003 08:47:03 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C7818@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18bidJ-0007u1-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Jan 2003 06:47:09 -0800
To: "Chris Adams" <chris@improbable.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

We are using udp mounts, and we have now conformed that it is
not related to using the Auspex.  We have duplicated a crash against
a raidzone nfs server, so it is some sort of application/client nfs=20
interaction.

Currently tests are being done with 2.4.21pre3+NFSALL to see if
it duplicates.

			Roger

> -----Original Message-----
> From:	Chris Adams [SMTP:chris@improbable.org]
> Sent:	Thursday, January 23, 2003 2:48 AM
> To:	Heflin, Roger A.
> Cc:	nfs@lists.sourceforge.net
> Subject:	Re: [NFS] Linux NFS client against Auspex server crashes
>=20
> On Tuesday, January 21, 2003, at 07:54  AM, Heflin, Roger A. wrote:
> > 	I have a group I work with that is using Linux 2.4.19,
> > 	NFSALL (Oct-Nov timeframe), they are reporting that their machines
> > 	lock up (process space quits responding) on multiple machines =
running
> > 	almost identical jobs (with almost identical start times) at the=20
> > about same
> > 	time.  They are running against a Auspex server of some sort.
>=20
> I don't know if you've already tried this, but try using UDP mounts if =

> you aren't. TCP with our NS2000 was a nightmare with 2.4.x kernels -=20
> hung processes, odd mount behaviour, hard freezes, etc.
>=20
> Chris
>=20


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
