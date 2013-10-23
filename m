Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60404 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897Ab3JWWS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Oct 2013 18:18:26 -0400
Date: Thu, 24 Oct 2013 09:18:11 +1100
From: NeilBrown <neilb@suse.de>
To: tasleson@redhat.com
Cc: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
Message-ID: <20131024091811.34b06e71@notabene.brown>
In-Reply-To: <52680917.4010509@redhat.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
	<20131022092519.4f4683a8@notabene.brown>
	<52669862.6030409@redhat.com>
	<20131023124444.65ace6e3@notabene.brown>
	<52680917.4010509@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nzPObRlmG8FJhblGahCLogJ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nzPObRlmG8FJhblGahCLogJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Oct 2013 12:36:23 -0500 Tony Asleson <tasleson@redhat.com> wrote:

> On 10/22/2013 08:44 PM, NeilBrown wrote:
> > On Tue, 22 Oct 2013 10:23:14 -0500 Tony Asleson <tasleson@redhat.com> w=
rote:
> >> The reason I chose to return values was to make sure requested operati=
on
> >> actually completed requested operation.  Unexporting a non-existent
> >> export is not considered an error and returns no indication you did
> >> absolutely nothing.
> >=20
> > Hi,
> >  thanks makes sense - I had missed that (even though you explained it i=
n the
> >  patch description :-( )
> >=20
> >  With your patch, if asked to unexport something that wasn't exported it
> >  would not report any error, but would exit with an error status.  Is t=
hat
> >  correct?  I think I would rather have a message printed if there is an=
 error.
>=20
> Correct, I only made changes for the exit status.  I was trying to make
> changes that would be mostly invisible to end users.  I have no concerns
> adding a printed error output too, but others may.
>=20
> Changing the behavior of any command line tool is potentially
> problematic when scripted.
>=20
> >  So would something like this (on top of my patch) address you need, or=
 was
> >  there something else I missed?
>=20
> Yes, this should work for the unexport fs case.
>=20
> However, the reason my patch was a little more invasive was to ensure
> that both the export and unexport paths were covered.
>=20
> For example, if the strdup call fails in function client_init, we fail
> the operation and return exit value of 0.  Unlikely, but just the first
> example I stumbled across.

I think it is a lot closer to "impossible" than just "unlikely".
malloc doesn't fail in this sort of context, the OOM killer kills something
off instead.
My personal preference is to replace all malloc/calloc/strdup calls with
the xmalloc, xstrdup etc calls in support/nfs/xcommon.c.
If you are worried about malloc failing, I'd much prefer to see a patch whi=
ch
changes nfs-utils to use those uniformly.

There might be a question over the best behaviour for daemons like mountd
and  gssd.  However as we move towards having systemd manage those, they wi=
ll
be restarted if they ever exit, and they are mostly stateless so that is
quite safe.

Does anyone else have thoughts on this?

NeilBrown

--Sig_/nzPObRlmG8FJhblGahCLogJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmhLIznsnt1WYoG5AQIAYg/9GiwuVvkqYZKRUOsAOF+4MCQAu2QgfiMB
Eu7PE1IJ112FbJZYcZoFlWbiZUuF5XEmU23ScSNTBSWMsT2WxNcIsSKpcVBMRmDc
5G43sEaJl1RxwhrPRQnHgIjSZjgwpWdIh2uF78ETbwNDWzr9/L1qrxJR7Mhmimv4
wTtRQIjwaab6hFb9ETia1otBeHbtOThvnW7oGZ/BJFVC5sQ1JlEJiCMgfNPTS3Km
v/RhJ4POaqvr5aqfwILc/so3+slZUjTs84KHVq45TIKGk7boywAJG/Gv5XYRTLZN
hfSlL2ssmtVNLyUxkx5y2PrsoAbHXrVJBBAV17LSHusA5SeJjySQDMFUuZofy82z
sWUjICFqhybybTZ8/3RrM/hPItBx409EdsZzZedjPo2v1duAGuyop9Lf7RRLTSXg
xVSUC4r+u6yL3Sm3Ppfw+oVMt5NiBzx8aA71dq5KEDtfa7hHukerwH8NrG3Sk2hC
v7Zzw5hiO2slO0tG/ROjjUgeWHu5My8QjnscPz9L5SyN9nkJfCY+OSc6omT3IEVK
NNFEu9MVyLB97jmghQmI8BozuqO5CTdjiDKdJjU6GtszVtImZJyujaNp2TLzR604
8HmtckBd66qZSwOuEek8F73vka2ZJdpkvl3GZtclRH7PNPK/BOQkpnbDZXO2mtUm
fkdO2QilpcY=
=fi+R
-----END PGP SIGNATURE-----

--Sig_/nzPObRlmG8FJhblGahCLogJ--
