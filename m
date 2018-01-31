Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-sn1nam01on0080.outbound.protection.outlook.com ([104.47.32.80]:43328
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751447AbeAaPGV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 10:06:21 -0500
From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH v1] xprtrdma: Fix calculation of ri_max_send_sges
Date: Wed, 31 Jan 2018 15:06:19 +0000
Message-ID: <CY1PR0701MB2012AD8665B6DDCE033B518088FB0@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <20180130205344.13588.11646.stgit@manet.1015granger.net>
 <CY1PR0701MB201216E6A13D1BC0E4A74FDB88FB0@CY1PR0701MB2012.namprd07.prod.outlook.com>
 <65A80728-B565-4E03-B50A-4F22FC1342DA@oracle.com>
In-Reply-To: <65A80728-B565-4E03-B50A-4F22FC1342DA@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Wednesday, January 31, 2018 5:04 PM
> To: Kalderon, Michal <Michal.Kalderon@cavium.com>
> Cc: linux-rdma@vger.kernel.org; Linux NFS Mailing List <linux-
> nfs@vger.kernel.org>
> Subject: Re: [PATCH v1] xprtrdma: Fix calculation of ri_max_send_sges
>=20
>=20
>=20
> > On Jan 31, 2018, at 9:04 AM, Kalderon, Michal
> <Michal.Kalderon@cavium.com> wrote:
> >
> >> From: Chuck Lever [mailto:chucklever@gmail.com] On Behalf Of Chuck
> >> Lever
> >> Sent: Tuesday, January 30, 2018 10:54 PM
> >> To: Kalderon, Michal <Michal.Kalderon@cavium.com>
> >> Cc: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> >> Subject: [PATCH v1] xprtrdma: Fix calculation of ri_max_send_sges
> >>
> >> Commit 16f906d66cd7 ("xprtrdma: Reduce required number of send
> >> SGEs") introduced the rpcrdma_ia::ri_max_send_sges field. This fixes
> >> a problem where xprtrdma would not work if the device's max_sge
> >> capability was small (low single digits).
> >>
> >> At least RPCRDMA_MIN_SEND_SGES are needed for the inline parts of
> >> each RPC. ri_max_send_sges is set to this value:
> >>
> >>  ia->ri_max_send_sges =3D max_sge - RPCRDMA_MIN_SEND_SGES;
> >>
> >> Then when marshaling each RPC, rpcrdma_args_inline uses that value to
> >> determine whether the device has enough Send SGEs to convey an NFS
> >> WRITE payload inline, or whether instead a Read chunk is required.
> >>
> >> More recently, commit ae72950abf99 ("xprtrdma: Add data structure to
> >> manage RDMA Send arguments") used the ri_max_send_sges value to
> >> calculate the size of an array, but that commit erroneously assumed
> >> ri_max_send_sges contains a value similar to the device's max_sge,
> >> and not one that was reduced by the minimum SGE count.
> >>
> >> This assumption results in the calculated size of the sendctx's Send
> >> SGE array to be too small. When the array is used to marshal an RPC,
> >> the code can write Send SGEs into the following sendctx element in tha=
t
> array, corrupting it.
> >> When the device's max_sge is large, this issue is entirely harmless;
> >> but it results in an oops in the provider's post_send method, if
> >> dev.attrs.max_sge is small.
> >>
> >> So let's straighten this out: ri_max_send_sges will now contain a
> >> value with the same meaning as dev.attrs.max_sge, which makes the
> >> code easier to understand, and enables rpcrdma_sendctx_create to
> >> calculate the size of the SGE array correctly.
> >>
> >> Reported-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> >> Fixes: 16f906d66cd7 ("xprtrdma: Reduce required number of send SGEs")
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
> >> net/sunrpc/xprtrdma/verbs.c    |    2 +-
> >> 2 files changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c
> >> b/net/sunrpc/xprtrdma/rpc_rdma.c index 162e5dd..f0855a9 100644
> >> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> >> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> >> @@ -143,7 +143,7 @@ static bool rpcrdma_args_inline(struct
> >> rpcrdma_xprt *r_xprt,
> >> 	if (xdr->page_len) {
> >> 		remaining =3D xdr->page_len;
> >> 		offset =3D offset_in_page(xdr->page_base);
> >> -		count =3D 0;
> >> +		count =3D RPCRDMA_MIN_SEND_SGES;
> >> 		while (remaining) {
> >> 			remaining -=3D min_t(unsigned int,
> >> 					   PAGE_SIZE - offset, remaining); diff
> --git
> >> a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c index
> >> f4eb63e..bb56b9d 100644
> >> --- a/net/sunrpc/xprtrdma/verbs.c
> >> +++ b/net/sunrpc/xprtrdma/verbs.c
> >> @@ -505,7 +505,7 @@
> >> 		pr_warn("rpcrdma: HCA provides only %d send SGEs\n",
> max_sge);
> >> 		return -ENOMEM;
> >> 	}
> >> -	ia->ri_max_send_sges =3D max_sge - RPCRDMA_MIN_SEND_SGES;
> >> +	ia->ri_max_send_sges =3D max_sge;
> >>
> >> 	if (ia->ri_device->attrs.max_qp_wr <=3D RPCRDMA_BACKWARD_WRS)
> {
> >> 		dprintk("RPC:       %s: insufficient wqe's available\n",
> >
> > thanks, this fixed our first issue of mount failing.
>=20
> May I add "Tested-by: Michal Kalderon <Michal.Kalderon@cavium.com>" ?
>=20
> --
> Chuck Lever
>=20
>=20
sure
