Return-Path: <weston.andros.adamson@gmail.com>
Sender: Weston Andros Adamson <weston.andros.adamson@gmail.com>
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: non-contiguous write across SCSI layout
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <A9FB7499-6B5B-4D21-8077-C6E94814F5A4@redhat.com>
Date: Thu, 9 Jun 2016 14:00:35 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <92AB25FB-FB0C-4DF6-A542-4FB875F69B07@monkey.org>
References: <A0E027A5-A8E1-402C-890C-89C2AE5E4FE1@redhat.com> <585C6DB8-1D8F-4001-9B23-1C25F1DC4743@monkey.org> <A9FB7499-6B5B-4D21-8077-C6E94814F5A4@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 9, 2016, at 1:37 PM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> On 9 Jun 2016, at 10:17, Weston Andros Adamson wrote:
>=20
>>> On Jun 8, 2016, at 10:45 AM, Benjamin Coddington =
<bcodding@redhat.com> wrote:
>>>=20
>>> Hi Dros,
>>>=20
>>> The client takes this WARN_ON_ONCE path pretty often in
>>> pnfs_generic_pg_test() with SCSI layout type and generic/010:
>>>=20
>>> 1925     if (pgio->pg_lseg) {
>>> 1926         seg_end =3D end_offset(pgio->pg_lseg->pls_range.offset,
>>> 1927                      pgio->pg_lseg->pls_range.length);
>>> 1928         req_start =3D req_offset(req);
>>> 1929         WARN_ON_ONCE(req_start >=3D seg_end);
>>> 1930         /* start of request is past the last byte of this =
segment */
>>> 1931         if (req_start >=3D seg_end) {
>>> 1932             /* reference the new lseg */
>>> 1933             if (pgio->pg_ops->pg_cleanup)
>>> 1934                 pgio->pg_ops->pg_cleanup(pgio);
>>> 1935             if (pgio->pg_ops->pg_init)
>>> 1936                 pgio->pg_ops->pg_init(pgio, req);
>>> 1937             return 0;
>>> 1938         }
>>>=20
>>> I'm trying to figure out why that's a WARN-able path.. do you recall =
the
>>> original reason for that warning?
>>=20
>> What=E2=80=99s happening here is that the pgio descriptor spans =
multiple layout segments.
>>=20
>> IIRC this points to a problem with the pg_test call. It shouldn=E2=80=99=
t allow requests
>> from different lsegs to be coalesced.
>=20
> Ok, but we're in pg_test right now in something like:
>=20
> pnfs_generic_pg_test
> bl_pg_test_write
> nfs_pageio_add_request
> nfs_do_writepage
>=20
> So, bl_pg_test_write is the pg_test op for the block layout, and it =
calls
> through to pnfs_generic_pg_test to do the job of checking if the =
request is
> outside the layout.

Hrm, oh this is *in* pnfs_generic_pg_test! Something else is going on =
here.

It=E2=80=99s been a long time since I was in there, but IIRC the =
nfs_can_coalesce_requests
call should not be coalescing reqs with different lsegs. It doesn=E2=80=99=
t appear to check
for that anymore!?=20

>=20
> Would you rather keep the warn and have the layout-specific pg_test op =
check
> that we don't cross a segment boundary?  If not, I think we can =
probably
> drop this warn unless it is useful to the other layouts

I don=E2=80=99t have the cycles right now to dig much further, but this =
sure looks wrong to me.
Doesn=E2=80=99t the code as-is switch the pgio-wide lseg to the new one =
from @req, then
return 0, meaning that 0 bytes from @req =E2=80=9Cfit=E2=80=9D into =
pgio? How is that right?
Doesn=E2=80=99t this use the wrong lseg?

Note that there are currently zero servers (that I am aware of) that =
hand out
file/flexfile layouts with more than one segment...

-dros
