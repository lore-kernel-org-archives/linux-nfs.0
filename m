Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6083C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 05:02:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ACB8E20818
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 05:02:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725848AbfBVFCd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 00:02:33 -0500
Received: from mx2.suse.de ([195.135.220.15]:51142 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725855AbfBVFCd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 00:02:33 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 1EE95B178;
        Fri, 22 Feb 2019 05:02:31 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Fri, 22 Feb 2019 16:02:24 +1100
Subject: Re: Another OPEN / OPEN_DOWNGRADE race
In-Reply-To: <b09d70c86e962a93555b30ead4d1c283c43198b7.camel@hammerspace.com>
References: <874l8wwsed.fsf@notabene.neil.brown.name> <b09d70c86e962a93555b30ead4d1c283c43198b7.camel@hammerspace.com>
Message-ID: <87tvgwv2jj.fsf@notabene.neil.brown.name>
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

> Hi Neil
>
> On Fri, 2019-02-22 at 11:58 +1100, NeilBrown wrote:
>> Hi,
>>  I have a report of an NFSv4.1 state management problem in our 4.4
>>  kernel which appears to be caused by a race between OPEN and
>>  OPEN_DOWNGRADE, and I don't think the race is fixed in mainline.
>>=20
>>  The test program creates multiple threads which open a file O_RDWR
>> and
>>  write to it, then opens for O_RDONLY and reads from it.
>>  A network trace which shows the problem suggests that at a point in
>>  time where there are some O_RDONLY opens and one O_RDWR open, a new
>>  O_RDWR open is requested just as the O_RDWR open is being closed.
>>=20
>>  The close of the O_RDWR clears state->n_rdwr early so
>> can_open_cached()
>>  fails for the O_RDWR open, and it needs to go to the server.
>>  The open for O_RDWR doesn't increment n_rdwr until after the open
>>  succeeds, so nfs4_close_prepare sees
>>     n_rdwr =3D=3D 0
>>     n_rdonly > 0
>>     NFS_O_RDWR_STATE and NFS_O_RDONLY_STATE set
>>  which causes it to choose an OPEN_DOWNGRADE.
>>=20
>>  What we see is a OPEN/share-all and an OPEN_DOWNGRADE/share-read
>>  request are sent one after the other without waiting for a reply.
>>  The OPEN is processed first, then the OPEN_DOWNGRADE, resulting in a
>>  state that only allows reads.  Then a WRITE is attempted which
>> fails.
>>  This enters a infinite loop with 2 steps:
>>   - a WRITE gets NFS4ERR_OPENMODE
>>   - a TEST_STATEID succeeds
>>=20
>>  Once an OPEN/share-all request has been sent, it isn't really
>> correct
>>  to send an OPEN_DOWNGRADE/share-read request.  However the fact that
>>  the OPEN has been sent isn't visible to nfs4_close_prepare().
>>=20
>>  There is an asymmetry between open and close w.r.t. updating the
>>  n_[mode] counter and setting the NFS_O_mode_STATE bits.
>>=20
>>  For close, the counter is decremented, then the server is told, then
>>  the state bits are cleared.
>>  For open, the counter and state bits are both cleared after the
>> server
>>  is asked.
>>=20
>>  I understand that this is probably because the OPEN could fail, and
>>  incrementing a counter before we are sure of success seems
>> unwise.  But
>>  doing so would allow us to avoid the incorrect OPEN_DOWNGRADE.
>>=20
>>  Any suggestions on what a good solution would look like?  Does it
>> ever
>>  make sense for an OPEN request to be concurrent with a CLOSE or
>>  OPEN_DOWNGRADE ??  Maybe they should be serialized with each other
>>  (maybe not as fully serialized as NFSv4.0, but more than they
>> currently
>>  are in NFSv4.1)

Hi Trond,
 thanks for the reply.

>
> If the CLOSE/OPEN_DOWNGRADE is processed by the server _after_ the
> OPEN, then the stateid presented by the client will have an incorrect
> seqid, and so the server should reject the operation with a
> NFS4ERR_OLD_STATEID.

According to RFC5661, section  18.18.3, the DESCRIPTION of
OPEN_DOWNGRADE,

    The seqid argument is not used in NFSv4.1, MAY be any value, and
    MUST be ignored by the server.

So the fact that the stateid passed (3) is less than the stateids
already returned for some OPEN operations (4 and 5), the server MUST
still process the OPEN_DOWNGRADE, not give an error.


>
> If, on the other hand, the CLOSE/OPEN_DOWNGRADE is processed before the
> OPEN, then the client should either see a new stateid with a new
> 'other' field (CLOSE) or it will see the same stateid but with a seqid
> that does not match what it expects (OPEN_DOWNGRADE). In the current
> mainline code, the client will then attempt to wait for any "missing"
> seqids to get processed (see nfs_set_open_stateid_locked()).

Hmm.. I don't have the waiting in my 4.4 code - I should probably make
sure I understand that.  However the tcpdump trace shows that this
scenario isn't what is happening, so it isn't immediately relevant.

Thanks,
NeilBrown

>
> Cheers
>   Trond
>
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlxvgmAACgkQOeye3VZi
gbl6vRAAnyQWiLQyWHyTntt/rbP0icDGwiox51AWOOKgWYDcdT9Z3SzSWZK6aG/4
7obDFhKfkBQC2bYt/hi7ED7srefIBtX7cLggENEkWObdk3l+Xwyi1+oWawLVa3V6
FM0gN4ghFYwOGITe0gpCv3OSGimbxvG/L3mJXrbbwFkN9/uq228i7QkPJ4Ik90om
4OLIxS/0rgh/FJq1B5mi9GK33i7J4N0x0edAEaFLIhblO26tD+GEFvqzfUS/agt7
IfJuBW+RGkqfQgaSzJrbRaiAq2TSb+WGk+H/QJJX+FvPWqmk4YVDyz44bVkmEwLI
NxyadlmwQfvcsiAz2SfHXuupxEGVI2DwcYkcQysiMAYITG1d2jtnwULFC1ZnVuoP
4U28u5YszNXehWd7UQGNin55dq2EcMW3oWX1lf9sd4HgYPDZpfcjroXZWZgAqCK+
1ZySOQbFlFUbevRds8nHcb6GEamNgPoDyLiqYhnxIDrdsDpSI83EuAVeD0EebtjI
0fyVDiCtzQYbZf96/NvFm+jk2seYsrUBPHLRbc0UgaVb36t5ngRqxhGz1EtwmkFv
AikPzep66fIaIB9KN0g+aBgnEQl06Z1FB7DzDTeAk1QEm3GW2DrIbh+CCpsO+tG/
enpv49Od9s5Jc4KE6ClS9YOzdFh1dkEZHhE/siieYDNHo15Nf5A=
=ejSR
-----END PGP SIGNATURE-----
--=-=-=--
