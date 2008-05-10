From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2] nfs: use compound hdr.status to override op status.
Date: Sat, 10 May 2008 10:24:36 -0700
Message-ID: <1210440276.12927.0.camel@localhost>
References: <47F0F6AB.3030302@panasas.com>
	<1206974900-368-1-git-send-email-bhalevy@panasas.com>
	<1207002349.15341.15.camel@heimdal.trondhjem.org>
	<47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>
	<4824E08E.6070401@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4824E08E.6070401@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-05-09 at 16:38 -0700, Benny Halevy wrote:
> >From 513dd2b4ebab280343db4bf6071b75c4820089fc Mon Sep 17 00:00:00 2001
> From: Benny Halevy <bhalevy@panasas.com>
> Date: Tue, 1 Apr 2008 12:41:08 +0300
> Subject: [PATCH 1/1 v2] nfs: use compound hdr.status to override op status.
> 
> The compound header status must be equivalent to the
> status of the last operation in the compound results.
> In certain cases like lack of resources or xdr decoding error,
> the nfs server may return a non-zero status in the compound header
> which is not returned by any operation.  In this case we would
> notice that today when looking for the respective operations
> code in the results and we return -EIO when we cannot find it.
> This patch fixes that by returning the status available in the
> compound header instead.
> 
> This patch also fixes 3 call sites where we looked at the compound
> hdr.status in the success case which is useless (yet benign).
> These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |   84 +++++++++++++++++++++++++----------------------------
>  1 files changed, 40 insertions(+), 44 deletions(-)
> 
> Changes in PATCH v2:
> * rebased onto 2.6.26 (off of linux-2.6 28a4acb4)
> * fixed checkpatch.pl nits
> * do not fixup status in nfs4_xdr_enc_setacl
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5a2d649..57b512e 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3791,6 +3791,9 @@ static int decode_delegreturn(struct xdr_stream *xdr)
>  	return decode_op_hdr(xdr, OP_DELEGRETURN);
>  }
>  
> +#define nfs4_fixup_status(status, hdr_status) \
> +	(likely(!status) ? 0 : nfs4_stat_to_errno(hdr_status))
> +

static function please!

  Trond
