From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: NFS mount option - noac forces sync even if async is specified, and no warning is given
Date: Wed, 5 Feb 2003 15:50:24 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A32806@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18gXRC-0007fq-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Feb 2003 13:50:34 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

> .
>=20
> then trond's suggestion of reducing the attribute cache timeout
> values to zero is your answer for now.
>=20
	I have now put that into place.    We rely on the file creations
	and size changes to be seen immediately but cannot afford
	the performance hit to allow the writes to be sync, so we live
	with the application needing to be aware of this issue.  The =
application
	actually rsh's to the disk node and touchs the file to update
	its time so that the cache will be tossed on the remote nodes=20
	for a new open. Over the several seconds that we need things to=20
	be consistant this works fine.

> ah, but Solaris noac doesn't disable *data* caching.  data is still
> cached until the client detects the file has changed.  *writes* are
> no longer cached, but reads can hit the client's data cache as long
> as the file doesn't change on the server.
>=20
	Then their manpage is also wrong.  On 2.6 (and 2.8) it says:
	         noac           Suppress data and attribute caching.

	It sounds very much like they kill all caching, but who knows
	what they actually do.


> besides, when was the last time you found that documentation matched
> implementation 100% on any operating system?
>=20
	Not as of yet, though some are close than others.  At least with
	linux I can get an answer in a reasonable time frame.

> >     And mount does not scream about
> > 	noac and async being non-compatible.
>=20
> arguable.  there are plenty of combinations of mount options that are
> inadvisable or ineffective.  here's a good one:
>=20
>   mount -o soft,udp,rsize=3D1024,wsize=3D1024,timeo=3D2
>=20
> another good one:
>=20
>   mount -o tcp,timeo=3D1
>=20
> here's an interesting case that neither works nor complains:
>=20
>   mount -t nfs -o tcp
>   mount -t nfs -o udp,remount
>=20
> or how about this, which isn't dangerous, but has no effect:
>=20
>   mount -t nfs -o noatime
>=20
> is mount supposed to know about all combinations for all file systems,
> and make sure you never make a mistake?  perhaps better checking can
> and should be added to the NFS client over time.  and maybe even the
> combination of "noac,async" should be made to work as you expect.
>=20
	I would agree lots of those are inadvisable, but at least it does=20
	in the proper unix way do exactly what you told it to, noac,async
	does not, it ignores the explicit option, ignoring an explicit option
	and shooting someone in the foot is rather worse, than letting you=20
	shot yourself because you pointed at your foot and pulled the
	trigger things to.

	I almost think Sun did the noac option the way they did because
	the did not have the sync/async option to use, so they rolled
	too many things into one.   And you are correct probably initially
	it was noac and then later became noac,syncwrites.

	I wish I still had a SunOS 4 machine to check and see
	how it worked on there.

	                            Roger


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
