From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: NFS mount option - noac forces sync even if async is specified, and no warning is given
Date: Tue, 4 Feb 2003 10:04:16 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A7FE43@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18g5Z1-0002IV-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 08:04:47 -0800
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




> noac without sync writes doesn't make much sense, does it?
> noac is used to cause multiple clients to share files pretty
> tightly.  even if client A is aggressively checking a server
> for changes to a file, it will not detect changes unless
> all the other clients send their writes as submitted by the
> app, rather than delaying them.
>=20
> solaris noac has always behaved this way, and Linux noac
> has behaved like this since around 2.4.7.
>=20
	We don't expect to get the writes another client does=20
	immediately, we want to see the file creates/attribute changes
	close to real time, not the data itself, the applications have
	a way of dealing with the data not being in sync, and don't
	even expect it to be consistant over the short term.

	I think the problem is with the name, noac which is explained
	as no attribute caching, and on Suns it is explained as no
	data and attribute caching (I just checkd the man) not exactly
	a consistant naming on Sun's part.  It should probably be=20
	called nocache since that appears to be what it is doing.
	Changing linux to be more consistant with Sun, but less
	consistant with previous version of linux nfs should at least be=20
	documented a little better.


> > If I remove the noac option, then the async option seems to=20
> > be honered, but not with the noac option on the line, is this=20
> > the documented=20
> > behavior?  And should something give a warning since one user=20
> > specified options overrides another user specified option in a=20
> > very nonobvious way?
>=20
> noac is a synonym for "actimeo=3D0,sync" which is the behavior
> of least surprise in this case.  if you look at the Solaris
> man page which describes noac, you will see that Solaris's noac
> behaves this way.  maybe the Linux mount_nfs man page hasn't
> been updated to reflect this behavior.
>=20
	It is only the behavior of least suprise if you are using Solaris
	as the reference, not if you are using previous version of linux
	as the reference.

	None of the man pages document the behavior, and  mount
	should return a warning (at least) that the two options (noac,async)
	don't agree with each other.

> > The write performance stinks rather badly with the sync option=20
> > enabled, and I could see why you *might* want to force it=20
> > with noac, but not if the user is attempting to override the=20
> > sync option with async.
>=20
> synchronous writes are always slow.
>=20
> perhaps the real bug is that noac,async doesn't work the way
> you expect it.  i can think of only one instance where this
> might be desired: if the writing application resides on the
> file server.
>=20
	The real bug it there is no documentation on any of the recent
	changes, the man pages are completly useless, and horribly
	out of date.    Attribute caching was previously described as
	attributes, and then changed to be the same as
	Sun's definition of all caching, somewhat of a major change,
	with no documentation changes.  None of the man pages say
	anything aboue disabling *ALL* caching, and putting the client
	into sync mode.  And mount does not scream about
	noac and async being non-compatible.

> > SYNC is specified on the exports line on the remote server,=20
> > and my understanding was that you want sync on the exports line, and =

> > async on the mount line on the client, but I cannot seem to=20
> > get it to take async on the mount line (no error is given,=20
> > but it appears to have been ignored, trying a known bad=20
> > option -say nosync does give a error saying bad option).
>=20
> sync on the server side is not the same as sync on the client
> side.  take a look at the NFS FAQ or review the archives of
> this list to see why this is the case.
>=20
	I know all about this, I got burned by those options when the
	sync behavior was changed from the original probably incorrect
	definition of only sync on certain things (attributes and such)
	 to sync on all writes.  =20

	It would be very helpful if these major changes in how previous
	version worked were documented someplace, or at least put
	in the HOWTO or FAQ's.

					Roger


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
