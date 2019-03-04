Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69325C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 23:48:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 397FF206B6
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 23:48:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726098AbfCDXs6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 18:48:58 -0500
Received: from mx2.suse.de ([195.135.220.15]:36742 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726095AbfCDXs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 18:48:58 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id D8405ADC1;
        Mon,  4 Mar 2019 23:48:53 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Tue, 05 Mar 2019 10:48:45 +1100
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix memory corruption caused by readdir
In-Reply-To: <20190304164725.GE13690@fieldses.org>
References: <87lg1vs5eh.fsf@notabene.neil.brown.name> <20190304164725.GE13690@fieldses.org>
Message-ID: <877ederyjm.fsf@notabene.neil.brown.name>
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

On Mon, Mar 04 2019, J. Bruce Fields wrote:

> On Mon, Mar 04, 2019 at 02:08:22PM +1100, NeilBrown wrote:
>> (Note that the commit hash in the Fixes tag is from the 'history'
>>  tree - this bug predates git).
>> Fixes: eb229d253e6c ("[PATCH] kNFSd: fix two xdr-encode bugs for readdir=
plus reply")
>
> It'd be nice to provide a URL for that.  The one I originally cloned one
> seems to have disappeared.

Fixes-URL: https://git.kernel.org/pub/scm/linux/kernel/git/history/history.=
git/commit/?id=3Deb229d253e6c

Though on reflection, that didn't introduce the bug, it just failed to
fix it properly.  It should be:

Fixes: 0b1d57cf7654 ("[PATCH] kNFSd: Fix nfs3 dentry encoding")
Fixes-URL: https://git.kernel.org/pub/scm/linux/kernel/git/history/history.=
git/commit/?id=3D0b1d57cf7654

>

>> Cc: stable@vger.kernel.org (v2.6.12+)
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>=20
>> Can I still get extra credit for fixing a bug that is 14.5 years old, if
>> I'm the one who introduced it?
>
> Good grief, yes!  Great fix.  Is that a record?
>
> And how did it go undetected so long, and what caused it to surface just
> now?

I suspect two different things need to come together to trigger the bug.
1/ a directory needs to have filename lengths which cause the xdr
   encoding of the readdirplus reply to place the offset across a page
   boundary.
   A typical entry is around 200 bytes, or 50 quads, so there should be
   a 1:50 chance of hitting that, assuming name lengths are evenly
   distributed (which they aren't).
   In the case which triggered the bug, all file names were 43 bytes,
   all filehandles 28 bytes. This means 192 bytes per entry.
   21 entries fit in a page leaving 64 bytes.  This puts the cookie
   on the page boundary.

2/ The *next* entry after the one that crosses the page boundary doesn't
   fit.  In the cases which triggered, the requested size was 0x1110
   (4368).
   That is enough room for 21 entries, but not for 22.

So presumably the client doesn't run Linux - which always asks
for 4096 bytes of directory entry (from a Linux server).
I have no idea what clients the customer was using, but these clients
seem to have a fairly good chance of triggering the bug (when configured
like the customer configured them - maybe).

>
> I once thought about converting this over to the xdr_stream api that
> NFSv4 uses to hide the page-crossing logic now.  But I think it's better
> to leave it alone.

I agree - the code isn't being actively developed, so stability wins
over elegance.


BTW, the readdir (non-plus) code doesn't really need fixing.
nfs3svc_decode_readdirargs() caps the ->count at PAGE_SIZE, so the cookie
can never cross pages. nfs3svc_decode_readdirplusargs() caps it
at max_blocksize.  So if you feel like leaving that part of the change
out, I probably wouldn't complain.

Thanks,
NeilBrown

>
> --b.
>
>>=20
>>  fs/nfsd/nfs3proc.c | 16 ++++++++++++++--
>>  fs/nfsd/nfs3xdr.c  |  1 +
>>  2 files changed, 15 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>> index 9eb8086ea841..c9cf46e0c040 100644
>> --- a/fs/nfsd/nfs3proc.c
>> +++ b/fs/nfsd/nfs3proc.c
>> @@ -463,8 +463,19 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
>>  					&resp->common, nfs3svc_encode_entry);
>>  	memcpy(resp->verf, argp->verf, 8);
>>  	resp->count =3D resp->buffer - argp->buffer;
>> -	if (resp->offset)
>> -		xdr_encode_hyper(resp->offset, argp->cookie);
>> +	if (resp->offset) {
>> +		loff_t offset =3D argp->cookie;
>> +
>> +		if (unlikely(resp->offset1)) {
>> +			/* we ended up with offset on a page boundary */
>> +			*resp->offset =3D htonl(offset >> 32);
>> +			*resp->offset1 =3D htonl(offset & 0xffffffff);
>> +			resp->offset1 =3D NULL;
>> +		} else {
>> +			xdr_encode_hyper(resp->offset, offset);
>> +		}
>> +		resp->offset =3D NULL;
>> +	}
>>=20=20
>>  	RETURN_STATUS(nfserr);
>>  }
>> @@ -533,6 +544,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
>>  		} else {
>>  			xdr_encode_hyper(resp->offset, offset);
>>  		}
>> +		resp->offset =3D NULL;
>>  	}
>>=20=20
>>  	RETURN_STATUS(nfserr);
>> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
>> index 9b973f4f7d01..83919116d5cb 100644
>> --- a/fs/nfsd/nfs3xdr.c
>> +++ b/fs/nfsd/nfs3xdr.c
>> @@ -921,6 +921,7 @@ encode_entry(struct readdir_cd *ccd, const char *nam=
e, int namlen,
>>  		} else {
>>  			xdr_encode_hyper(cd->offset, offset64);
>>  		}
>> +		cd->offset =3D NULL;
>>  	}
>>=20=20
>>  	/*
>> --=20
>> 2.14.0.rc0.dirty
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlx9uV0ACgkQOeye3VZi
gbky4Q//Z5AWbh/lnaOGlKsI6a1mYW5eydPR+waDfj+NZJKlLZg7I+Ump7hDJVqb
JaW3wXmG4tIjdsIU6j2M6qr2LvR6q/wR4z0CSW08nBPtxGcuo6eUAFj7z3IMLQ2f
XPx3G3tWyxpiITK2fI26yZY6S74lOrkgmuEtrAYJmC102uBTflgoz4CiOYaMg8dI
/ioGG6trVZw2X4L7i8SkpeDGiV7vrjzVkodI2FUfyCbnGuQtBMLeZCZpQi5LFRZr
zvodSvmkvUKEjXG8XvNuGNS4aBoet6S7+Jen60zyAcYVIt8dHIIxwbY9P90dv11y
eY8IRtpsO9Sc9BGEZPaaYI+Q8M1csWbLyrYfwDavb5UpdV5vqbuhllwYxeMls/zg
u7dtPMW1K8KHLivIv3brq58htHq3/O8AAcd8qKYvsPdMi37n7TEdz3yIMJ/qLdZU
g19qnXpCWPq/qheuVE2R5yhm+Cbo4nosoaHyRzlUBAOL9S1tH1ha5jW3/QVyT3mg
7sc8GuEFfMLV7LQ1FX8ZIVQrneezbactbRNqmSyc0F8ytr3T0GJdsSRKLrCbF4Mz
dpmw5aDkrq3ZHE6xI8CL6rfQo/o+mbVswKSIl9PrEsgPgf/XYHnNdnbOLLABXJLq
RfAdoB40oalQBVA4tBeSoLudiUSI4QzrQ9LU8wYwX7LwMU7yHr4=
=EUDx
-----END PGP SIGNATURE-----
--=-=-=--
