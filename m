Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49078 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751032AbdIHFGe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Sep 2017 01:06:34 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 08 Sep 2017 15:06:24 +1000
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/3] nfsd: clients don't need to break their own delegations
In-Reply-To: <20170907220149.GC4731@fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-4-git-send-email-bfields@redhat.com> <87bmn0ia6i.fsf@notabene.neil.brown.name> <20170907220149.GC4731@fieldses.org>
Message-ID: <8760ctbwz3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07 2017, J. Bruce Fields wrote:

> On Mon, Aug 28, 2017 at 02:32:53PM +1000, NeilBrown wrote:
>> /* legacy typedef, should eventually be removed */
>> typedef void *fl_owner_t;
>>=20
>>=20
>> Maybe you could do the world a favor and remove fl_owner_t in a
>> preliminary patch :-)
>
> Partly scripted, still a bit tedious, but I think it's right.  Honestly
> I don't know what the motivation for the comment was, though.  Are there
> no documentation or type-checking benefits to having the typdef?

If it was an established practice throughout the kernel to use typedefs
to differentiate different 'void *', then maybe there would be a
documentation benefit.  Given the wide use of casts (you removed 9 I
think), I don't think there are significant type-checking benefits.

I don't like fl_owner_t because when you see it in the general context
of the kernel, you are likely to think that it means something
important.  Then you go hunting and find "Oh, it is just a void*". (That
is what happened to me:-).  The second reason that I don't like it is
that it requires all those casts that you removed.

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


>
> The main annoyance was having this defined as a files_struct pointer,
> which Christoph fixed some time ago.
>
> --b.
>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmyJVIACgkQOeye3VZi
gbkYNg/+P8A/dbOIOmyx5mfPERKy5q1RL57+ZwVf3zhnSnQg5rmL5FlH/CXjEzqz
ZC+dlzFbitn9YnGK7bz4TsBLLKnQ3GlYOyzqP0y5R7h7UUDUFhJRecLPZzLxjSt1
rHGl8vBnRMlRivp+TLqSbour4+VtFzNI9j/4Jg+i0TfvHpbheyYPhJsLAp5CvdG5
WwNq5ztVUfLWKVcw7jMBGbGmrEdsIC+uqpF8aU4Mx94XCMMHkmQJDHHqDlEMn4NV
yBahrjuJLN/5wq48tKlCQBPhFV9TpHSuIIe+u4PbcHGgq2397zajXNYYs2eR8uD4
h5wbqJnRwCiPvX0W648OHA1p9mlI2h0I5k1roCmtT/Ijr3LlVXF7NHTrXGZfqjeh
N1rgvtCSkjNPvSyciuNo8TyOxFpOfQE+eOT2eYbERfbc3YEJmRP/qwcwcis5UYwl
fSCXhWzRK6NKnTpeU9OBBrgzfX9Ew35dY44oGrA9SRBNU5Sv9FJts71sikQX6vjs
1gPuixWX+YOBcfxBWpbDTdvv08BDiPi4BRJ5GlnFtFWGKMZudjk1i3VxsiPXKAqy
yjCVO4DnG4WSuANoB0ntSFM7Mko2UwQk+da/bZC1VeabY32lk8pXwgrWTZNxZiYP
jN8a/kOL4oksLupzB+cQlkB/PpcNVQSnX/TnwTq/VS4rC/06K18=
=IKxP
-----END PGP SIGNATURE-----
--=-=-=--
