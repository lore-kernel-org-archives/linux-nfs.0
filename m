Return-Path: <weston.andros.adamson@gmail.com>
Sender: Weston Andros Adamson <weston.andros.adamson@gmail.com>
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: non-contiguous write across SCSI layout
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <A0E027A5-A8E1-402C-890C-89C2AE5E4FE1@redhat.com>
Date: Thu, 9 Jun 2016 10:17:29 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <585C6DB8-1D8F-4001-9B23-1C25F1DC4743@monkey.org>
References: <A0E027A5-A8E1-402C-890C-89C2AE5E4FE1@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 8, 2016, at 10:45 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> Hi Dros,
>=20
> The client takes this WARN_ON_ONCE path pretty often in
> pnfs_generic_pg_test() with SCSI layout type and generic/010:
>=20
> 1925     if (pgio->pg_lseg) {
> 1926         seg_end =3D end_offset(pgio->pg_lseg->pls_range.offset,
> 1927                      pgio->pg_lseg->pls_range.length);
> 1928         req_start =3D req_offset(req);
> 1929         WARN_ON_ONCE(req_start >=3D seg_end);
> 1930         /* start of request is past the last byte of this segment =
*/
> 1931         if (req_start >=3D seg_end) {
> 1932             /* reference the new lseg */
> 1933             if (pgio->pg_ops->pg_cleanup)
> 1934                 pgio->pg_ops->pg_cleanup(pgio);
> 1935             if (pgio->pg_ops->pg_init)
> 1936                 pgio->pg_ops->pg_init(pgio, req);
> 1937             return 0;
> 1938         }
>=20
> I'm trying to figure out why that's a WARN-able path.. do you recall =
the
> original reason for that warning?

What=92s happening here is that the pgio descriptor spans multiple =
layout segments.

IIRC this points to a problem with the pg_test call. It shouldn=92t =
allow requests
from different lsegs to be coalesced.

-dros
