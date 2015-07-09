Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222AbbGIWSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2015 18:18:33 -0400
Message-ID: <559EF332.7060103@redhat.com>
Date: Thu, 09 Jul 2015 18:18:26 -0400
From: Doug Ledford <dledford@redhat.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
CC: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il> <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com> <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com>
In-Reply-To: <20150709000337.GE16812@obsidianresearch.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8oiAjIwtKHxADMuf6biGgrhkVNXfbjDBT"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8oiAjIwtKHxADMuf6biGgrhkVNXfbjDBT
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/08/2015 08:03 PM, Jason Gunthorpe wrote:
> On Wed, Jul 08, 2015 at 01:32:05PM -0700, 'Christoph Hellwig' wrote:
>> On Wed, Jul 08, 2015 at 01:08:42PM -0600, Jason Gunthorpe wrote:
>>> Then, what is left is all remote MRs and maybe it will be clearer wha=
t
>>> to do about them then...
>>
>> From looking at that for a while the APIs needed seem pretty simple
>> to me from a consumer perspective:
>>
>> struct rdma_mr *rmda_alloc_mr(struct ib_pd *pd, unsigned int nr_pages)=
;
>> void rdma_free_mr(struct rdma_mr *mr);
>=20
> The major trouble with that is that the new MR types work by posting
> work to the send queue, that work creates the MR.
>=20
> I don't know all the details of how those schemes work, but it doesn't
> look like it fits into this model ?
>=20
> Maybe if rdma_register_sg was the only API and it accepted a QP, under
> the hood it could re-use a pooled/create a non-queued (F)MR, or issue
> FRMR, or work with indirect?
>=20
> It would be nice if it is that simple :)
>=20
> Sagi, are FMRs, FRMRs and Indirect MRs documented any place? I can't
> recall off hand if FRMR was ever published by the IBTA?

A lot of this discussion is interesting and has gone off in an area that
I think is worth pursuing in the long run.  However, in the short run,
this patch was a minor cleanup/simplification patch.  These discussions
are moving into complete redesigns and rearchitecting.  Steve, I'm OK
with the cleanup and would prefer that it stay separate from these
larger issues.

Baby steps, one things at a time.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--8oiAjIwtKHxADMuf6biGgrhkVNXfbjDBT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVnvMyAAoJELgmozMOVy/doQgP/j8jxwYDfzdSSk1p/ubmogjU
ShhL1+R17fpSFRlAojvo6cQADWnAhOpTHN9kJSWD9mTiwpEDUkfl+JjBOSvrBUHH
bpTR7QeiLgie6HlwMVShcTziQYmWSmVjcDwDuUEhm9lX0W3i+EXidqru1ed1PDK3
I7Hzs5Hdf7b9R5d3AGbZWTSa451kIqzrnftPoU8k1kY9WUUSKjNGZcysHPxwNNDL
1oOHhYDw5pgNf2N3KpKUKsPWSH6Q5IUKV8L2BCSuFI+9brqPxOL49vG8TwvPZ/hm
IxNnIA6kM6xXisoqPoLgWh3lWhJTc01uE4u0DrIdiyHuJXGaZ0NovH7L4k2sKW4U
1oJAPjWitHc8AZ++qQA1tFQMv+ZF7+xRTMVFl5861Yl26lkzAekzIi64F3vP/uyZ
1Vp4DPW+e7VuIU2kzhmrLnQiXHnWR60sSxmpekcDWpQvP7v5hBW2t0Fn224qwnTS
kaBexdw92i/w0oemsxqQaKald8z8TVk/ykTaU/qPSdUgECLHr3imbq6dbk6z4l15
ncripXAxLs89yN1NsQY6mnMFaae+X5oQWfUgn/JA532M8FqGZA3yGeyDgCR72iwt
zHh+IBJpNT1hODRl4vmHksuu0Kv46OYCrRjzKhzAhpy049phOlnQqc9WaMYsY7uX
8QSOp6VghJZl5YGb+Xmd
=7KHm
-----END PGP SIGNATURE-----

--8oiAjIwtKHxADMuf6biGgrhkVNXfbjDBT--
