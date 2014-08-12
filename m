Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:54319 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbaHLXrk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 19:47:40 -0400
Received: by mail-qc0-f172.google.com with SMTP id i8so3561705qcq.3
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 16:47:39 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 12 Aug 2014 19:47:36 -0400
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] locks: move most locks_release_private calls
 outside of i_lock
Message-ID: <20140812194736.3184fce4@tlielax.poochiereds.net>
In-Reply-To: <20140813082827.1097c3ad@canb.auug.org.au>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
	<20140813082827.1097c3ad@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/kxYLXrXQl0u7I2tdLiDGKVx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kxYLXrXQl0u7I2tdLiDGKVx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Aug 2014 08:28:27 +1000
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Jeff,
>=20
> On Tue, 12 Aug 2014 10:48:08 -0400 Jeff Layton <jlayton@primarydata.com> =
wrote:
> >
> > Absent any objections, I'll plan to merge these for 3.18.
>=20
> This means that this patch set should *not* be in linux-next until after
> (at least) v3.17-rc1 is released ...  This s reinforced by the lack of
> Acked-by, Reviewed-by and Tested-by tags ... (the addition of which would=
 presumably require the rebase (or rewrite) of a published git tree.)
>=20

It would, but I sent a later reply that revised that statement.

Trond pointed out that this problem can cause a user-triggerable oops,
so we may have to merge it for 3.17 after all. With that in mind, I
added these to my linux-next branch and will probably send a pull
request before the window closes (assuming that there are no glaring
problems with it).

While we're on the subject, we probably ought to rename my tree in your
"Trees" file from "file-private-locks" to "file-locks" or something.
File private locks (aka OFD locks) got merged in v3.15, but I have been
collecting patches that touch fs/locks.c

> /me suspects that many people do not read his daily release notes :-(

Guilty as charged. I'll try to keep up in the future.

Thanks,
--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/kxYLXrXQl0u7I2tdLiDGKVx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT6qeYAAoJEAAOaEEZVoIVJWwP/2IOnANkv4Ay2E/QHApA+Guw
jft1AXNRN/ymISGt+qMV0r1DSN5vReV6YlsqYHrDS3W2UHrx1jpSLqd5uRb4Ozou
MnHKj96Sd1ci0Iav2puzPti3Rusm2zxH8Rfxct0XJjhswwYsB6dFAtcFSUQbF9+R
HjyWYxI2A7JDFFMgD81CjMm0/OcM68YEIhNrJFcI3pHe8vilhVKmr5kv1/h6Zxzc
1fs2K0RxC6sxuEXqgMN7npX/jdgXMzWrF8YAAXrHtA3bhc1N1mk6LgU3jNGDtp1c
ORSXYAXAEfDKr5FIsSxrKdAm92SN5jQKlBEP2EtDUUmmR4bDZ+2TpY5xDMetRdRv
auois8k1HtP4Z+TeFDJJIyL+IJCdg9ZQREe829KiXsa1SlqxF/sRre1RakpDBWur
wHJVXaUrCbuelUZ7LJb3ogoaHkTD5Xrz4IudzgiRTPt2Fe7tcN6SJ6R9h00k3rFo
5QyI8uLZM52TyUvyVvB1syy2r7SJCul5d8Rzh/jSENER4tNh46tUXijWnWhduTN7
EvTgJaVNq/Q0uqSVOzQWfBcC76lUCNGml8OvSVBLmCzMxbY2MxAnSWPZs/yAt85m
KxOMiojPGLDOyWrnSonkopU6Cyr7WEJlVZyzhHWHUGx9j5CBUpAZqUD7c8OSF8q8
rbiTkW1IrdCfbArw1xyu
=Ccvm
-----END PGP SIGNATURE-----

--Sig_/kxYLXrXQl0u7I2tdLiDGKVx--
