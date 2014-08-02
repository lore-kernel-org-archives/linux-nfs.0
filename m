Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbaHBDUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 23:20:07 -0400
Date: Sat, 2 Aug 2014 13:19:46 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Ben Greear <greearb@candelatech.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
Message-ID: <20140802131946.207c597c@notabene.brown>
In-Reply-To: <CAABAsM7eh-Faaqmb9yf_xCVwi3cGpnTeOT8A4-e1jhwuEMPKWQ@mail.gmail.com>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<20140801075053.2120cb33@notabene.brown>
	<20140801212120.1ae0eb02@tlielax.poochiereds.net>
	<CAABAsM7eh-Faaqmb9yf_xCVwi3cGpnTeOT8A4-e1jhwuEMPKWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/EEnww1=jFLDDwB=.9eVfr5p"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/EEnww1=jFLDDwB=.9eVfr5p
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 1 Aug 2014 22:55:42 -0400 Trond Myklebust <trondmy@gmail.com> wrote:

> > That still leaves some open questions though...
> >
> > Is that enough to fix it? You'd still have the dirty pages lingering
> > around, right? Would a umount -f presumably work at that point?
>=20
> 'umount -f' will kill any outstanding RPC calls that are causing the
> mount to hang, but doesn't do anything to change page states or NFS
> file/lock states.

Should it though?

       MNT_FORCE (since Linux 2.1.116)
              Force  unmount  even  if busy.  This can cause data loss.  (O=
nly
              for NFS mounts.)

Given that data loss is explicitly permitted, I suspect it should.

Can we make MNT_FORCE on NFS not only abort outstanding RPC calls, but
fail all subsequent RPC calls?  That might make it really useful.   You
wouldn't even need to "kill -9" then.

NeilBrown

--Sig_/EEnww1=jFLDDwB=.9eVfr5p
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU9xY2Tnsnt1WYoG5AQJ1XA/7B4djzTDFNSOEbZB1eY4ZHSD2yCrOGpwG
0FBUJYDvy4bMpnDahcgVSabI6ov3hFPqHxWWF9oO4fNIZVXgWdHp2MqA3I0zaoWm
2BDVl8CJE1DMfQ4sMasx5W+HroB+g7UIfCg6KtaqdxfsxYIMXmcecKNJTwS9YUiq
jIQdXIk9PJFm5xzv9K4pk5If5m6VMfSzfg3xD0CAD3CpnvjZ45NVux6QQQ5EZTsd
eSEv0wVNKEBLPeVoYVfJ3YtIbP9E+sC/boOFAzJtoU9Ftj8odz19qlPa27JrMHMd
w4+Ttc2fWGkrDJ/IuI1MP3vYggiwN7OBDp8KJecQtSyWFolWjv59ZU1t2Vj57uhk
wLAUV80FOH0EdVqNlYj/XXMtaJVSFdatTP3tBZnSvK/MIKYHP1NPOjBR4Cwreeg7
PPjP5QzrXXi4bPQPh2RIlybKzlvh2dFnQrFu75w9LuuyKFtIa6nxqqJueIa8bHSg
HXWOA96nSgsyJpaUDAcmmrH1p2fDOi6Z+wAU9rbOVzv52XITDg6gyqDtrZoTyELs
OcS1SoNB6RQams3z3+cl4otK1jHTY7W04Eow2N2gnsuPBFOfiOOk/7B5qm9sl0Bg
eyO1TaRDP1J5mES71+v/Oh5Q+oQmvGyzq8CyAr4FhzEdrfVhDCMMiqhv5RLWLvWy
EmjIfQIXUhE=
=NAMK
-----END PGP SIGNATURE-----

--Sig_/EEnww1=jFLDDwB=.9eVfr5p--
