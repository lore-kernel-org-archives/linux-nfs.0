Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([103.22.144.67]:43886 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753093AbaHMCJQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 22:09:16 -0400
Date: Wed, 13 Aug 2014 12:09:07 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] locks: move most locks_release_private calls
 outside of i_lock
Message-ID: <20140813120907.33c5584a@canb.auug.org.au>
In-Reply-To: <20140812194736.3184fce4@tlielax.poochiereds.net>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
	<20140813082827.1097c3ad@canb.auug.org.au>
	<20140812194736.3184fce4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/uJ0dE+bqlGu==x_x2ME.BTt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/uJ0dE+bqlGu==x_x2ME.BTt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Tue, 12 Aug 2014 19:47:36 -0400 Jeff Layton <jeff.layton@primarydata.com=
> wrote:
>
> On Wed, 13 Aug 2014 08:28:27 +1000
> Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>=20
> > On Tue, 12 Aug 2014 10:48:08 -0400 Jeff Layton <jlayton@primarydata.com=
> wrote:
> > >
> > > Absent any objections, I'll plan to merge these for 3.18.
> >=20
> > This means that this patch set should *not* be in linux-next until after
> > (at least) v3.17-rc1 is released ...  This s reinforced by the lack of
> > Acked-by, Reviewed-by and Tested-by tags ... (the addition of which wou=
ld
> > presumably require the rebase (or rewrite) of a published git tree.)
>=20
> It would, but I sent a later reply that revised that statement.
>=20
> Trond pointed out that this problem can cause a user-triggerable oops,
> so we may have to merge it for 3.17 after all. With that in mind, I
> added these to my linux-next branch and will probably send a pull
> request before the window closes (assuming that there are no glaring
> problems with it).

OK, fine.  I have merged it today in any case.

> While we're on the subject, we probably ought to rename my tree in your
> "Trees" file from "file-private-locks" to "file-locks" or something.
> File private locks (aka OFD locks) got merged in v3.15, but I have been
> collecting patches that touch fs/locks.c

OK, I will do that tomorrow.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/uJ0dE+bqlGu==x_x2ME.BTt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT6sjJAAoJEMDTa8Ir7ZwV+P0P/0WHMJbEG92a1tE+5hFJhDUy
H6QMpgtHiHT4zMxqHR9bqNyxDKAuNLUXrFph4I0cpr7xu6/SMPNem9UpFH5VDuFc
W6c0X9NAmXvHjmXdxQf33rZmeAfhGHyvtaImi7ZUnnyW2ercOlqk0k9gFbpoQErC
3wycMbgLomDrkEXbrgB2sVMycyqeIRCJbHm9GE79KO0WRLVu8XwnigPn6sZFo7Vl
cCP9ZPfu/pn9NYvZzlYEQditKGULCV9wY/lKPDylnisPqPUTXx91SB5/CsHua3Js
W4hjhghhqYpcUqM+mFLll6Ob1ywBJYccuGwr7vOvICg3geipmrHe6G39pAYf5igW
TTlxJiBVTuPvyqite3P5e7+NAnDBpXjzT5M/MexCrp951GiNtpPTdJtd8I9Kq5R5
mwqIDTDb9Aw0vebTRx3AfmYl9afifMG4wrPwPXulIIMkM8kvKp3ZWQG/+mGBABhm
+ZtRN/kxGZQOq331kUnJ/bqeAV7jYM5DgOW6ZsgAKC9kt4A3bfRar+fdUKDs5hOM
NMw/pXm1RAFJEDvXosL+QR+WRCB4A8LiQXhYGGjppbsPGXj2ifCBvUS01WgNuY7M
dgmDTlpp7njzEuezQWiVr0o4Ua2yw2+Uf/IuHHgVKdRzUsY3B3hLtPB6/hSz/SJU
u6StAEfP4RWSR6B7kuny
=muyF
-----END PGP SIGNATURE-----

--Sig_/uJ0dE+bqlGu==x_x2ME.BTt--
