Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933607AbdEVVag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 17:30:36 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Weston Andros Adamson" <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfs: Fix the check for requests in range of layout
 segment
Date: Mon, 22 May 2017 17:30:34 -0400
Message-ID: <447399F0-689F-45FB-9291-5798821B838A@redhat.com>
In-Reply-To: <bf2ea18703f605c6fcfe698f5a59c6062ca590ed.1495477047.git.bcodding@redhat.com>
References: <bf2ea18703f605c6fcfe698f5a59c6062ca590ed.1495477047.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 22 May 2017, at 14:20, Benjamin Coddington wrote:

> It's possible and acceptable for NFS to attempt to add requests beyond 
> the
> range of the current pgio->pg_lseg, a case which should be caught and
> limited by the pg_test operation.  However, the current handling of 
> this
> case replaces pgio->pg_lseg with a new layout segment (after a WARN) 
> within
> that pg_test operation.  That will cause all the previously added 
> requests
> to be submitted with this new layout segment, which may not be valid 
> for
> those requests.
>
> Fix this problem by only returning zero for the number of bytes to 
> coalesce
> from pg_test for this case which allows any previously added requests 
> to
> complete on the current layout segment.  The check for requests 
> starting
> out of range of the layout segment moves to pg_init, so that the
> replacement of pgio->pg_lseg will be done when the next request is 
> added.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/pnfs.c | 27 +++++++++++++++++++--------
>  fs/nfs/pnfs.h | 10 ++++++++++
>  2 files changed, 29 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index adc6ec28d4b5..0c26de3d3914 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2094,12 +2094,28 @@ pnfs_generic_pg_check_layout(struct 
> nfs_pageio_descriptor *pgio)
>  }
>  EXPORT_SYMBOL_GPL(pnfs_generic_pg_check_layout);
>
> +/*
> + * Check for any intersection between the request and the 
> pgio->pg_lseg,
> + * and if none, put this pgio->pg_lseg away.
> + */
> +static void
> +pnfs_generic_pg_check_range(struct nfs_pageio_descriptor *pgio, 
> struct nfs_page *req)
> +{
> +	if (pgio->pg_lseg && !pnfs_lseg_request_intersecting(pgio->pg_lseg, 
> req)) {
> +		if (pgio->pg_ops->pg_cleanup)
> +			pgio->pg_ops->pg_cleanup(pgio);
> +		else
> +			pnfs_generic_pg_cleanup(pgio);

Actually, I think this ^^ should be put_lseg(), pgio->pg_lseg = NULL
instead, since we're already within pg_init.  The layouts might have 
work
that would be undone by pg_cleanup..  I'll send a v2 after a short wait 
for
comment.

Ben

