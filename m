From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 8 Sep 2008 15:02:22 -0700
Message-ID: <20080908220222.GA15261@merfinllc.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080908190212.GF28123@merfinllc.com> <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:41911 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753250AbYIHWCX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2008 18:02:23 -0400
In-Reply-To: <76bd70e30809081415h6b55a8dfl8171634c576ac946-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Chuck,

On Sep 08 05:15 PM, Chuck Lever wrote:
> This seems to correspond with the strace logs, which show that you
> stopped the bad run before it generated more writes.

Yes.  Sorry.   I stopped the writer once the reader saw the NULL bytes.

> Normally this isn't a big deal, as NFS likes applications to serialize
> access to shared files.  However, in this case we expect the .flush()
> to force all dirty bytes out at once, and this is definitely not
> occurring....
>=20
> The third thing is that I don't see any flush or fsync system calls in
> the strace logs, even though the writer.py script invokes fp.flush().
> I'm not terribly familiar with Python's flush().  How do you expect
> the flush() method to work?

I think fp.flush() in Python is equivalent to fflush() i.e. it only
flushes the stdio buffer.  It doesn't actually call fsync or fdatasync
or anything like that.

We can pretty easily change the Python code to use the syscall
write()/etc methods.

> I wonder why the client is using FILE_SYNC writes and not
> UNSTABLE+COMMIT. Are the clients using the "sync" mount option?  I
> don't see O_SYNC on the open.

I've exported them on the server as sync e.g. in exports:

  /export		192.168.0.0/24(rw,sync)

However I don't give any special options when mounting e.e. on the
client:

  mount machine:/export  mntpnt

Anyway thanks for looking at this and let me know if I can do anything
else!


					=3Da=3D


--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFIxaDur/o4YuvB+jgRAvDoAJ0XQYEZpSomuOsDScUPfZYv5POEQgCgmGHM
kiF6KMn3tbU3vd2KcyX6dPs=
=IiuB
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
