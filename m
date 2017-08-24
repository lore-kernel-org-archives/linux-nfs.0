Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32816 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751038AbdHXEHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 00:07:17 -0400
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Thu, 24 Aug 2017 14:07:05 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com> <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com> <87h8x1l9qp.fsf@notabene.neil.brown.name> <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com> <87r2w3jdn5.fsf@notabene.neil.brown.name> <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <87inhdk3rq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Aug 23 2017, Ian Kent wrote:

>
> That inconsistency has bothered me for quite a while now.
>
> It was carried over from the autofs module behavior when automounting
> support was added to the VFS. What's worse is it prevents the use of
> the AT_NO_AUTOMOUNT flag from working properly with fstatat(2) and with
> statx().
>
> There is some risk in changing that so it does work but it really does
> need to work to enable userspace to not trigger an automount by using
> this flag.
>
> So that's (hopefully) going to change soonish, see:
> http://ozlabs.org/~akpm/mmotm/broken-out/autofs-fix-at_no_automount-not-being-honored.patch
>
> The result should be that stat family calls don't trigger automounts except
> for fstatat(2) and statx() which will require the AT_NO_AUTOMOUNT flag.
>

oooh, yes.  That's much better - thanks.

We should make sure that change gets into the man pages...

First however, we should probably correct the man page!
stat.2 says:


  NOTES
       On Linux, lstat() will generally not trigger  automounter
       action,  whereas  stat()  will  (but  see  the description of
       fstatat() AT_NO_AUTOMOUNT fag, above).

which is wrong: lstat and stat treat automounts the same.
@Michael: do you recall why you inserted that text?  The commit message
in commit 1ef5b2805471 ("stat.2: Cosmetic reworking of timestamp
discussion in NOTES") is not very helpful.

I propose correcting to

  NOTES:
      On Linux, lstat() nor stat() act as though AT_NO_AUTOMOUNT was set
      and will not trigger automounter action for direct automount
      points, though they may (prior to 4.14) for indirect automount
      points.


The more precise details, that automount action for indirect automount
points is not triggered when the 'browse' option is used, is probably
not necessary.

Ian: if you agree with that text, and Michael doesn't provide alternate
evidence, I'll submit a formal patch for the man page.... or should we
just wait until the patch actually lands?

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmeUOoACgkQOeye3VZi
gbmVXBAAlvOIy/xCBLiJLacO0vWGkBsYePn/Rjcv93/Ynj4wdKhEILh3wQDYnnMk
THP3gsQPI2mwkxPwpUnS+t7LzJbF7hsntBZ00lcFrYCx1BWvo7XGBYCzTVSYiwVI
9SLUuRu1jWz00saxRq1XGOOg2RCt9QAcQ+8rYXceq8ZyqNgCd46pmavrgKTbiYaT
2BXMA6K7Xg93tOw8aNgZ4LxkghiEvMz7yzfmlinPnpFr992AXrtVWy+GhUPvG9Zf
XuUPGocPzpTfE4USZwicVXw4mtTVUQ+SUJ8LLy4oKVoCb/u4W85gb/y8T3JkWpm6
FQQNqIXw70WvHUim4JoOgBWu15Nnpn/cPZMAGQIm3ZE1cv76MU4e/Q3FyyUZ0vKX
MmwLubmThjl1QuzZC3uH1gL4yp7i0DNtBdn/pK4Bie6F+KZcEDMHEguflRHNgX98
W84z6bCfxLu75u4BltthBmst4qsXZq1ydJXJF9HBHwsi/QqOILhIWK16o9v2iSnH
cMhFFj6wSzMU4+EM6Ks0gLAceUgs3LC0cwMyZ+mDAGVtVMLW1Clb6q0w4Ll1qvRS
+Efwm1gukR4VeOn1VJG3BMNSkWbepLdw9fjQ/MDooZaa3Xbh01rw3Erh70S68phT
7ZKKQOIauvOXmOSqpFAeDtWdniPCPeT1TGhatReeC16HtwTXgbU=
=PQlW
-----END PGP SIGNATURE-----
--=-=-=--
