Return-Path: <SRS0=i0gF=Q6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E538C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 01:22:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 64B252077B
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 01:22:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725814AbfBWBWb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 20:22:31 -0500
Received: from mx2.suse.de ([195.135.220.15]:52978 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725811AbfBWBWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 20:22:31 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 5E9E1B04F;
        Sat, 23 Feb 2019 01:22:30 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Sat, 23 Feb 2019 12:22:24 +1100
Subject: Re: Another OPEN / OPEN_DOWNGRADE race
In-Reply-To: <6b2eecda4f82a1628a25f44d792b4bfeb90a6a65.camel@hammerspace.com>
References: <874l8wwsed.fsf@notabene.neil.brown.name> <b09d70c86e962a93555b30ead4d1c283c43198b7.camel@hammerspace.com> <87tvgwv2jj.fsf@notabene.neil.brown.name> <6b2eecda4f82a1628a25f44d792b4bfeb90a6a65.camel@hammerspace.com>
Message-ID: <87imxbuwmn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 22 2019, Trond Myklebust wrote:

> Hi Neil,
>
> On Fri, 2019-02-22 at 16:02 +1100, NeilBrown wrote:
>> On Fri, Feb 22 2019, Trond Myklebust wrote:
>>=20
>> > Hi Neil
>> >=20
>> > On Fri, 2019-02-22 at 11:58 +1100, NeilBrown wrote:
>> > > Hi,
>> > >  I have a report of an NFSv4.1 state management problem in our
>> > > 4.4
>> > >  kernel which appears to be caused by a race between OPEN and
>> > >  OPEN_DOWNGRADE, and I don't think the race is fixed in mainline.
>> > >=20
>> > >  The test program creates multiple threads which open a file
>> > > O_RDWR
>> > > and
>> > >  write to it, then opens for O_RDONLY and reads from it.
>> > >  A network trace which shows the problem suggests that at a point
>> > > in
>> > >  time where there are some O_RDONLY opens and one O_RDWR open, a
>> > > new
>> > >  O_RDWR open is requested just as the O_RDWR open is being
>> > > closed.
>> > >=20
>> > >  The close of the O_RDWR clears state->n_rdwr early so
>> > > can_open_cached()
>> > >  fails for the O_RDWR open, and it needs to go to the server.
>> > >  The open for O_RDWR doesn't increment n_rdwr until after the
>> > > open
>> > >  succeeds, so nfs4_close_prepare sees
>> > >     n_rdwr =3D=3D 0
>> > >     n_rdonly > 0
>> > >     NFS_O_RDWR_STATE and NFS_O_RDONLY_STATE set
>> > >  which causes it to choose an OPEN_DOWNGRADE.
>> > >=20
>> > >  What we see is a OPEN/share-all and an OPEN_DOWNGRADE/share-read
>> > >  request are sent one after the other without waiting for a
>> > > reply.
>> > >  The OPEN is processed first, then the OPEN_DOWNGRADE, resulting
>> > > in a
>> > >  state that only allows reads.  Then a WRITE is attempted which
>> > > fails.
>> > >  This enters a infinite loop with 2 steps:
>> > >   - a WRITE gets NFS4ERR_OPENMODE
>> > >   - a TEST_STATEID succeeds
>> > >=20
>> > >  Once an OPEN/share-all request has been sent, it isn't really
>> > > correct
>> > >  to send an OPEN_DOWNGRADE/share-read request.  However the fact
>> > > that
>> > >  the OPEN has been sent isn't visible to nfs4_close_prepare().
>> > >=20
>> > >  There is an asymmetry between open and close w.r.t. updating the
>> > >  n_[mode] counter and setting the NFS_O_mode_STATE bits.
>> > >=20
>> > >  For close, the counter is decremented, then the server is told,
>> > > then
>> > >  the state bits are cleared.
>> > >  For open, the counter and state bits are both cleared after the
>> > > server
>> > >  is asked.
>> > >=20
>> > >  I understand that this is probably because the OPEN could fail,
>> > > and
>> > >  incrementing a counter before we are sure of success seems
>> > > unwise.  But
>> > >  doing so would allow us to avoid the incorrect OPEN_DOWNGRADE.
>> > >=20
>> > >  Any suggestions on what a good solution would look like?  Does
>> > > it
>> > > ever
>> > >  make sense for an OPEN request to be concurrent with a CLOSE or
>> > >  OPEN_DOWNGRADE ??  Maybe they should be serialized with each
>> > > other
>> > >  (maybe not as fully serialized as NFSv4.0, but more than they
>> > > currently
>> > >  are in NFSv4.1)
>>=20
>> Hi Trond,
>>  thanks for the reply.
>>=20
>> > If the CLOSE/OPEN_DOWNGRADE is processed by the server _after_ the
>> > OPEN, then the stateid presented by the client will have an
>> > incorrect
>> > seqid, and so the server should reject the operation with a
>> > NFS4ERR_OLD_STATEID.
>>=20
>> According to RFC5661, section  18.18.3, the DESCRIPTION of
>> OPEN_DOWNGRADE,
>>=20
>>     The seqid argument is not used in NFSv4.1, MAY be any value, and
>>     MUST be ignored by the server.
>>=20
>> So the fact that the stateid passed (3) is less than the stateids
>> already returned for some OPEN operations (4 and 5), the server MUST
>> still process the OPEN_DOWNGRADE, not give an error.
>
> That refers to the explicit "seqid" parameter in struct
> OPEN_DOWNGRADE4args. I'm referring to the seqid that constitutes the
> first 4 bytes of the stateid.
>
> In other words, I'm referring to the mechanism described here:=20
> https://tools.ietf.org/html/rfc5661#section-8.2.2
>
> Note that the Linux client doesn't ever set the stateid seqid to zero
> on CLOSE or OPEN_DOWNGRADE precisely because we rely on the
> NFS4ERR_OLD_STATEID mechanism to detect races with OPEN.

Ahhh, I had missed that there were two seqids in OPEN_DOWNGRADE, on in
the stateid, one not.
Makes sense now.

With that perspective, it is pretty clear that the server is
misbehaving.
The OPEN_DOWNGRADE presents a seqid of 3 and after returning two open
requests with seqids of 4 and 5, the server processes that
OPEN_DOWNGRADE without error and returns a seqid of 6.

Thanks a lot,

NeilBrown


>
>>=20
>> > If, on the other hand, the CLOSE/OPEN_DOWNGRADE is processed before
>> > the
>> > OPEN, then the client should either see a new stateid with a new
>> > 'other' field (CLOSE) or it will see the same stateid but with a
>> > seqid
>> > that does not match what it expects (OPEN_DOWNGRADE). In the
>> > current
>> > mainline code, the client will then attempt to wait for any
>> > "missing"
>> > seqids to get processed (see nfs_set_open_stateid_locked()).
>>=20
>> Hmm.. I don't have the waiting in my 4.4 code - I should probably
>> make
>> sure I understand that.  However the tcpdump trace shows that this
>> scenario isn't what is happening, so it isn't immediately relevant.
>>=20
>
> True. The waiting mechanism was introduced by commit c9399f21c215
> ("NFSv4: Fix OPEN / CLOSE race") in v4.15. We should probably have
> kicked that down the stable patch mechanism.
> Cheers
>   Trond
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlxwoFAACgkQOeye3VZi
gbkLTBAAlX5HlmL5eL7zX1gCfS5AfO6c8ldom9OTfmoLaiHYZXDA8Qp8fmYwpR5S
hW4jIyhlrUY6sFF+CoslDtmAHCOfG8Fzf6/SumP729nvMv3OMd7dRZfH4sSvu9Hh
95jP+/I1zbaNm7QgwwQxTN5b3I0Qh0cNdEWiZzpLQSFYpSiiGEVYucheq0qahxRS
1uHxlanxu8bWpoG0zkaio8gGVrk5d8yyVGx2kI8Ez4iSmG0aAERZpe7bZlCCNks1
06dMAvIrd+nhPvOQzo22NgOP8bOhr7THhaQzS8nOv+YZGsrjX78t0MPrlURUgpQw
3VbC8NrtQb/p5aMa4fMBIViWkV2o9CVcsHU780eT45SFQrg6c1AuMEBWgnS5WOhG
/hvOyDeylj8x/c0GzKQNfivcPPZsKcz6XbdTGqdojbWkfIpnsdxGd//lX24XL+iU
QXeFiliwqOWGR60bGGWmXmF1eIHmEHnscYz3Yznv7olzyK9QZkq2Jsd3+eU7SYcv
Xy2fPCfkJkH5yyfeL4EadtTGgsdYEZdUiqr2i17+V+feTdP/KUTn9iu6AS6h47A2
VCerGxuRAS8l/UE9e+OvqNUGP43DTwCqf9L/HR5W/PesPIzsZZ+uIosGp/X+tVK3
+vNUoy4HjZZ6BLWUIH47HfX9GDmU15fgdSb2V4Q4x84c7r99nCc=
=YI3w
-----END PGP SIGNATURE-----
--=-=-=--
