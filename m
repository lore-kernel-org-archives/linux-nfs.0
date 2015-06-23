Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48114 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932116AbbFWVeB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jun 2015 17:34:01 -0400
Date: Tue, 23 Jun 2015 17:34:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2] nfsd: nfsd4_cb_sequence_done() for processing more cb
 errors
Message-ID: <20150623213401.GB25319@fieldses.org>
References: <556D8C8D.50205@gmail.com>
 <55817CCE.1030704@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55817CCE.1030704@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2015 at 09:57:34PM +0800, Kinglong Mee wrote:
> When testing pnfs layout, nfsd got error NFS4ERR_SEQ_MISORDERED.
> It is caused by nfs return NFS4ERR_DELAY before validate_seqid(),
> don't update the sequnce id, but nfsd updates the sequnce id !!!
> 
> According to RFC5661 20.9.3,
> " If CB_SEQUENCE returns an error, then the state of the slot
> (sequence ID, cached reply) MUST NOT change."
> 
> This patch introduce a new helper nfsd4_cb_sequence_done() for
> processing more callback errors as client.
> 
> v2, 
> thanks Christoph's advice of adding a helper process errors as client

Thanks, could you rebase this on top of my for-4.2 branch?  (I already
took your earlier patch.)  Also:

> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4callback.c | 122 +++++++++++++++++++++++++++++++++++++------------
>  fs/nfsd/state.h        |   1 +
>  2 files changed, 93 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index ce8d3f2..6fce478 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
...
> @@ -874,6 +874,11 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
>  	struct nfs4_client *clp = cb->cb_clp;
>  	u32 minorversion = clp->cl_minorversion;
>  
> +	/*
> +	 * cb_seq_status is only set in decode_cb_sequence4res,
> +	 * and so will remain 1 if an rpc level failure occurs.
> +	 */
> +	cb->cb_seq_status = 1;

Isn't that a valid error code?  OK, I guess NFS4ERR_PERM isn't a legal
SEQUENCE return.  Still, -1 might make this a bit more obvious.

--b.
