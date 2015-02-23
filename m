Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50970 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbbBWEtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2015 23:49:11 -0500
Date: Mon, 23 Feb 2015 15:49:00 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150223154900.75f62422@notabene.brown>
In-Reply-To: <CAHQdGtTihwVemYehOs3mSKAw+o7NTVPy2hJi67Q=HDS34iQWfw@mail.gmail.com>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
	<20150216155429.46cfbab7@notabene.brown>
	<1424643211.4278.10.camel@primarydata.com>
	<20150223094747.040ce304@notabene.brown>
	<CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
	<20150223140526.3328468e@notabene.brown>
	<CAHQdGtTihwVemYehOs3mSKAw+o7NTVPy2hJi67Q=HDS34iQWfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/1etQZLiUAeSdsMWeY/2huJA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/1etQZLiUAeSdsMWeY/2huJA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 22 Feb 2015 22:33:28 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> > According to rfc1813, READDIRPLUS returns the filehandles in a "post_of=
_fh3"
> > structure which can optionally contain a filehandle.
> > The text says:
> >    One of the principles of this revision of the NFS protocol is to
> >    return the real value from the indicated operation and not an
> >    error from an incidental operation. The post_op_fh3 structure
> >    was designed to allow the server to recover from errors
> >    encountered while constructing a file handle.
> >
> > which suggests that the absence of a filehandle could possibly be inter=
preted
> > as an error having occurred, but it doesn't allow the client to guess
> > what that error might have been.
> > It certainly doesn't allow the client to deduce "you're not supposed to=
 ever
> > see this inode".
>=20
> NFSv3 had no concept of submounts so, quite frankly, it should not be
> considered authoritative in this case.

The presence or otherwise of submounts is tangential to the bug.
The spec implies that nothing can be deduced from the absence of a filehand=
le
in a READDIRPLUS reply, but the code appears to deduce something.  This is a
bug.  submounts happen to trigger it in the one case we have clear evidence
for.


>=20
> >> IOW: it is literally the case that the client is supposed to create a
> >> proxy inode because this is supposed to be a mountpoint.
> >
> > This may be valid in the specific case that we are talking to a Linux N=
FSv3
> > server (of a certain vintage).  It isn't generally valid.
> >
> >
> >>
> >> > I certainly agree that there may be other issues with this code.  It=
 is
> >> > unlikely to handle volatile filehandles well, and as you say, referr=
als may
> >> > well be an issue too.
> >> >
> >> > But surely if the server didn't return a valid filehandle, then it i=
s wrong
> >> > to pretend that "all-zeros" is a valid filehandle.  That is what the=
 current
> >> > code does.
> >>
> >> As long as we have a valid mounted-on-fileid or a valid fileid, then
> >> we can still discriminate. That is also what the current code does.
> >> The only really broken case is if the server returns no filehandle or
> >> fileid. AFAICS we should be handling that case correctly too in
> >> nfs_refresh_inode().
> >
> > When nfs_same_file() returns 'true', I agree that nfs_refresh_inode() d=
oes
> > the correct thing.
> > When nfs_same_file() returns 'false', (e.g. the server returns no
> > filehandle), then we don't even get to nfs_refresh_inode().
> >
> > When readdirplus returns the expected filehandle and/or  fileid, we sho=
uld
> > clearly refresh the cached attributed.  When it returns clearly differe=
nt
> > information it is reasonable to discard the cached information.
> > When it explicitly returns no information - there is nothing that can be
> > assumed.
>=20
> Your statement assumes that fh->size =3D=3D 0 implies the server returned
> no information. I strongly disagree.

I accept that a server might genuinely return a filehandle with a size of
zero for some one object (maybe a root directory or something).
In that case, this code:

		if (*p !=3D xdr_zero) {
			error =3D decode_nfs_fh3(xdr, entry->fh);
			if (unlikely(error)) {
				if (error =3D=3D -E2BIG)
					goto out_truncated;
				return error;
			}
		} else
			zero_nfs_fh3(entry->fh);

in nfs3_decode_dirent is wrong.
'zero_nfs_fh3' should not be used as that makes the non-existent filehandle
look like something that could be a genuine filehandle.
Rather something like
   entry->fh->size =3D=3D NFS_NO_FH_SIZE;
should be used, where NFS_NO_FH_SIZE is (NFS_MAXFHSIZE+1) or similar.

Or maybe entry->fh should  be set to NULL if no filehandle is present.


> No information =3D> fh->size =3D=3D 0, but the reverse is not the case, as
> you indeed admit in your changelog.

I didn't not mean to admit that.  I admitted that the server could genuinely
return a filehandle that was different to the one cached by the client.  I =
did
not mean that the server could genuinely return a filehandle with size of 0
(though I now agree that is possible as the spec doesn't forbid it).

On glancing through RFC1813 I noticed:

   Clients should use file handle
   comparisons only to improve performance, not for correct
   behavior.

This suggests that triggering an unmount when filehandles don't match is not
correct.  Flushing the cache is OK (that is a performance issue).  Removing
mountpoints is not.  So the change to d_invalidate() in 3.18 really isn't
very good for NFS.


>=20
> That said, we're talking about the Linux knfsd server here, which
> _always_ returns a filehandle unless there request races with an
> unlink or the entry is a mountpoint.

Surely the implementation should, where possible, be written to the spec, n=
ot
to some particular server implementation.

Thanks,
NeilBrown

--Sig_/1etQZLiUAeSdsMWeY/2huJA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOqxPDnsnt1WYoG5AQLszQ/+O1BAp7apAY6zi8tlm7D/QJZe8ZMOrQcB
hEZojWUNkiGEd4zpKZw4E/KV5DCZv06dwqUeZUrKa4wEg6FQIGv0vLpZGSpwxKA5
AhRz/ZVvzLP6TVaJQ3vsBePtJZ6IJEWN58fUEy8LO14UUUGeNi5hJn2vH3BZmfan
EBYjnOI+5yO4SfaWtcIqVsmMajGxO1sBZHHig/+tqJUPRdncZlOerWaXyK9ZMSx4
iCJsMB0dEyaks7aMT40PKY61SK0/H9yF6TNIganEnRC7++sLgec++09RNiFItZQw
c/qAZcxt+Kqw431tcAIrGtDRmPdq7mcNbMwn7t0ebIKy2g5Gl5ixPduBMJtb2oWE
hKV+n8AMOZ928QxJVJGYeXeK6NfeBtzYSFe8BIF4bBP5dbvkJUIFqm0fZK3/ly3V
GRgopElO2WsboLqHSnLSBe4DH5FH4Ft5+d7y7rIK/1TDnkCmr8lxBf5oqXaXwoIc
/Zr4iqYam2/w9ve7f0hibDirsFgRJMUH7u3jFmqABaeeNnuP+AqtU16J25JVTOYo
4LidpOlaO87UjBAv1hiWNd+eXdY/MWDyweB3oLSGMZ8sg2ncArvEuKeOld11o+F5
YGUjIMcBa68DQZVCa9Ce64SwEGqf224HBzGjc/JK7mdCiA5KlJhP9yXIKBDXIqLn
0JP+2yZaO8E=
=ytZK
-----END PGP SIGNATURE-----

--Sig_/1etQZLiUAeSdsMWeY/2huJA--
