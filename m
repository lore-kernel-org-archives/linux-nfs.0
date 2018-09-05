Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60086 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725853AbeIEE3x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 00:29:53 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 05 Sep 2018 10:02:17 +1000
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
In-Reply-To: <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
Message-ID: <87o9dcvmk6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 04 2018, Trond Myklebust wrote:

> On Wed, 2018-09-05 at 08:47 +1000, NeilBrown wrote:
>> With NFSv4.1, the server specifies max_rqst_sz and max_resp_sz in the
>> reply to CREATE session.
>>=20
>> If the client finds it needs to call nfs4_reset_session(), it might
>> get
>> smaller sizes back, so any pending read/writes would need to be
>> resized.
>>=20
>> However, I cannot see how the retry handling for reads/writes has any
>> chance to change the size.  It looks like a request is broken up to
>> match the original ->rsize and ->wsize, then those individual IO
>> requests can be retried, but the higher level request is never
>> re-evaluated in light of a new size.
>>=20
>> Am I missing something, or is this not supported at present?
>> If it isn't supported, any suggestions on how best to handle a
>> reduction of the rsize/wsize ??
>>=20
>
> Why would a sane server want to do this?

Why would a sane protocol support it? :-)

I have a network trace of SLE11-SP4 (3.0 based) talking to "a NetApp
appliance".
It sends a 64K write and gets NFS4ERR_REQ_TOO_BIG.
It then closes the file (getting NFS4ERR_SEQ_MISORDERED even though it
used a seq number 1 more than the WRITE request), and then
DESTROY_SESSION and CREATE_SESSION.
The CREATE_SESSION gets "max req size" of 33812 and "max resp size" of
33672.
It then opens the file again and retries the 64K write....

I have a separate trace showing the initial mount where the sizes are 71680
and 81920.

I don't have a trace where it stops working, but reportedly writes work
smoothly for some hours after a mount, but then suddenly stop working.

The CREATE_SESSION *call* requests I see have the small (32K) sizes, but
presumably they are the result of a previous CREATE_SESSION reply giving
a small value.

I just had a thought.
If one session is shared by two "struct nfs_server" with different
=2D>rsize or ->wsize, then the session might get set up with the smaller
size, and the mount using the larger size will get confused.
In 3.0 (and even 3.10) nfs4_init_session() limits the requested session
parameters to ->rsize and ->wsize.
That changed in 18aad3d552c7.

Maybe I just need to remove that code from nfs4_init_session().
I'll give it a try.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAluPHQkACgkQOeye3VZi
gbneLA//fd5U0yChbmIh2/830BAyqqsoW0YvwxExhJlt09VTJQeMOI0A6C6fYWN0
9nwFcRE1AdNHAFD7/1CBw5ZJic1/Pqe76nb3fmBOYqjlzVxqkCTHa2kIz1No2+NN
UJPpc9RByAgchdmlWYpqAvt6ALK8Rk1eL9QVGrYjCzTlhk11vFV2M92uq2WpCZ+V
Z/cyTvM/Z3wkWOGuyAnJNFVvYSpehQAZj6MuDAIleymOOdIO5/FeNc0Sw4TiJdk+
cp+PVLyx0vC/UGhwhU1z1CdtzN/LiaLgNOPR18jegtrgHL1RKDUK7XkMtJFVS8AG
dI7d2UU103V9gWNj/O8jWd0T5fBG1YnT9MjCie8X+9DejkFzu3k8mnogzu433cIA
XVjnntjT/zhbD8RlqlcDztgAS7ypH3hi7Q1mrSbpvF7YivzULqFjSIJUKFuDwpmz
grXYZYTmFKd0BkgtR/bqkG85Kh5dgBSIVFOAovk3pNlbvXP7YzmRI1D9QUlhqr+p
BVfaxksdskdGRH4YDAYpeRllXFJq1sumOMe/gcR2HR06HZmdBzfqiZoEI84KgMix
2NDwCVtUDrLg2OJmMlqRwheb5eps/Ll0beWIaAe/m8Apa4/Gkq41Gpv4A58T2SN1
pfl0JatXN/9TxJ+xWUOzNFMOJZrEt2ZFCLo+1OyHR9n9oaTiqjE=
=aHDc
-----END PGP SIGNATURE-----
--=-=-=--
