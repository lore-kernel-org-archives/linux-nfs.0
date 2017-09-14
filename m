Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51972 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751543AbdINWZh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 18:25:37 -0400
From: NeilBrown <neilb@suse.com>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
Date: Fri, 15 Sep 2017 08:25:23 +1000
Cc: Ian Kent <ikent@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: [PATCH manpages] stat.2: correct AT_NO_AUTOMOUNT text and general revisions.
In-Reply-To: <CAKgNAkinKkG8cR1ng0V3K1D9QNQ9MSeNkPpvpeGSUd5RqFiwSw@mail.gmail.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com> <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com> <87h8x1l9qp.fsf@notabene.neil.brown.name> <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com> <87r2w3jdn5.fsf@notabene.neil.brown.name> <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com> <87inhdk3rq.fsf@notabene.neil.brown.name> <CAKgNAki1SYjr7-6g-i3shGjQRjwy81gS0QisfZRy-x-bHFtXmA@mail.gmail.com> <87valci55j.fsf@notabene.neil.brown.name> <CAKgNAkinKkG8cR1ng0V3K1D9QNQ9MSeNkPpvpeGSUd5RqFiwSw@mail.gmail.com>
Message-ID: <87r2v89auk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Sep 14 2017, Michael Kerrisk (man-pages) wrote:

> Hi Neil,
>
> On 25 August 2017 at 07:32, NeilBrown <neilb@suse.com> wrote:
>>
>> Expand on the relationship between fstatat() and the other
>> three functions, and improve the description of AT_NO_AUTOMOUNT.
>> Specifically, both  stat() and lstat() act the same way
>> with respect to automounts, and that behavior matches
>> fstatat with the AT_NO_AUTOMOUNT flag.
>>
>> The text in the NOTES is removed and places with the text for
>> AT_NO_AUTOMOUNT to improve cohesion.
>>
>> New text for a difference to be introduced in 4.14.
>
> Has the 4.14 piece gone in?
>

Yes.

Commit: 42f461482178 ("autofs: fix AT_NO_AUTOMOUNT not being honored")

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm7AdQACgkQOeye3VZi
gbnHERAAoDDQf5i1aNFIMBZicAfDObxqec7VR6Ryy0nw0AHnUBQE5tCqhH3D7LaP
V4OwIGHq+lHcGu+va0Khdxxf/YX+OmXXI2BvL3FqqoOjen06mCzH9nT2GOOw1wUp
EKKgdE18290R+fUWS1ZB18oV1u4E4/o6/FdZSgPc8S8lFXGgvMvRvm2i75+42ejm
WnpC9GF3H0Hdx/slKzHy4t7oyPqIbyQq1HR8+ui24HEMuTk7v6Xl0ok3IqVRWWxN
xz8+kwvl/Zs+flYyf+hkRZheLz2Zj41TWRELIvEYBH67OZoh+OBfPp8Qjca9UOmN
suO7PvlmnPGziVmHjk+cyqOTBC0q2DHqONl2IlD/DmKG7cKKAGdCWqYJStwcbBNA
Zl6xobVdKJrXhWsaS+Eoys6AgQZ9/FCj0j02trREVXoGrBmdPDd6A61bszEPJF2D
ba6xVCm1XH3LWUJrp/yXNtMXiIfZxcijNenyXd1J1p4st9Is8A4LxkGJpUEe3pzs
iG127frPBla0I5GyN0/l6IlO0M5tkiRT2qdCuZdQI1C/5nZKhp+HgZOqXYUXUM+i
PLua2egebnroI8qkZjny3tEQtz5A5/zmZepTvzhPedw+9zYasNwuOz5zuIFPsms9
e+owD6Wf3W2RhxmW10vld87QOZhF7JN91CtZOrKxj14d4Ghfy2g=
=sKxl
-----END PGP SIGNATURE-----
--=-=-=--
