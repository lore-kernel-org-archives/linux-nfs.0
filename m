Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:45599 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141Ab1HTArg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 20:47:36 -0400
Date: Sat, 20 Aug 2011 02:47:34 +0200
From: Sylvain Rochet <gradator@gradator.net>
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sylvain Rochet <gradator@gradator.net>
Message-ID: <20110820004734.GA26693@gradator.net>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FCuugMFkClbJLl1L"
In-Reply-To: <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jamie,


On Sat, Aug 20, 2011 at 12:37:56AM +0100, Jamie Lokier wrote:
>=20
> Oh dear, that's a security hole, if something is using inotify/dnotify
> to watch and assumes that file contents (on the same machine,
> i.e. server in this case) do not change if there's no event received.
>=20
> It also breaks cache applications which make the same assumption.
>=20
> I do quite like the idea of using it to break past fanotify security
> restrictions though ;-)

It also probably means that fanotify misses some events when a filesystem=
=20
is modified over NFS. If fanotify is used the way it is designed, i.e.=20
with an antiviruse software, this may be an interesting way to skip the=20
antiviruse check.

Here we go:

NFS server, run the fanotify example tool:

~/fanotify-example# ./fanotify -m /data/

NFS client, open a fd then do some I/O:

# exec 1> test
# ls -la
#=20

NFS server log:

/data/test: pid=3D1235 modify close(writable)

NFS server, cache clearing:

# echo 3 > /proc/sys/vm/drop_caches=20

NFS client, more I/O:

# ls -la

NFS server log:

/data: pid=3D1234 modify close(writable)

We receive an event... which is obviously wrong. This is even worse than=20
no event at all, we receive an event about the wrong inode, the parent=20
inode of the modified file actually.


> Is a solution to open inotify watches on every file individually?  If=20
> so that seems quite severe.

This is what I am going to do, at least temporarily, I only need to=20
watch about a million file (and slowly counting).

The startup time to watch an entire filesystem using inotify already=20
require a full filesystem walk, watching all files and directories=20
instead of directories only will not change much because most of the=20
time is spent waiting I/O operations. This may however require a lot=20
more memory both on kernel side and userland side.


> Can it also be bypassed with sys_open_by_handle_at?

No clue, this should be checked but there is no evident reason that it=20
cannot be bypassed this way as well.


> Possible solution:
>=20
> One way to look at this as like NFS having a secret hard link to the
> file, which does not show up in st_nlink.
>=20
> Hard links are already a bit tricky with fsnotify and directory
> watches.  You can monitor a directory, but a file in it can change
> contents through another path.
>=20
> However, you can track changes of hard-linked files accurately by
> either putting a watch directly on all files whose st_nlink >=3D 2,
> and/or making sure you have watches on enough distinct directories
> that they contain st_nlink entries for the same file between them,
> because at least one of those directories will get an event.  This is
> quite practical: You watch the files directly, until such time as you
> have found all its links (if you ever do), then you can remove the
> direct file watches.

Yup, I agree.


> That gives me an idea to help with the NFS no-name watching:
>=20
> It looks like when a file is referenced by inode without a path, the
> problem is there's no path, so no directory inode to receive the
> event?

No filepath and no filename at all actually. There is no way to find the=20
(or "a" if the file is linked to more than one directory) filename other=20
than walking among all the directory tree to find where the inode is=20
linked. We need a directory entry (dirent) to send an event about a=20
modified file inside a watched directory.


> Then this can be solved, in principle (if there's no better way), by
> watching a "virtual directory" that gets all events for when the
> access doesn't have a parent directory.  There needs to be some way to
> watch it, and some way to get the appropriate file from the event (as
> there is no real directory.  Or maybe there could be a virtual
> filesystem (like /proc, /sys etc.) containing a magic directory that
> receives these inode-only events, such that lookups in that directory
> yield the affected file.  Exactly as if the directory contains a hard
> link to every file, perhaps a text encoding of the handles passed
> through sys_open_by_handle_at.

By doing that, we'll only get the inode nb as we cannot fetch the filename.


Sylvain

--FCuugMFkClbJLl1L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk5PBCYACgkQDFub3qtEsS/uAACgrguagPD+ZBQKB9izAVwXDCOh
xqYAoI66BOfqyobLgPJCGIU314QvZ6Sg
=mwcv
-----END PGP SIGNATURE-----

--FCuugMFkClbJLl1L--
