Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41604 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab2GSJ1g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jul 2012 05:27:36 -0400
Message-ID: <5007D2F9.6040500@panasas.com>
Date: Thu, 19 Jul 2012 12:27:21 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Idan Kedar <idank@tonian.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH] pnfs-obj: fix inline XDR size in _osd_xdr_decode_opaque_cred
References: <CAEMWVhsswo4SfRjVwDs5GG9g8t4hqkpqaan52xUq_XGi_E+L5w@mail.gmail.com> <1342603371-25211-1-git-send-email-idank@tonian.com>
In-Reply-To: <1342603371-25211-1-git-send-email-idank@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/18/2012 12:22 PM, Idan Kedar wrote:

> if the length is __be32, at least sizeof(__be32) bytes have to be
> decoded. this is just semantics since __xdr_inline_decode rounds nbytes
> up by calling XDR_QUADLEN(nbytes), but the code is still better off
> fixed.
> 


ACK-by: Boaz Harrosh <bharrosh@panasas.com>

> Signed-off-by: Idan Kedar <idank@tonian.com>


This is for Trond for the 3.6 merge window.

> ---
>  fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> index b3918f7..3845ece 100644
> --- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> +++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> @@ -73,7 +73,7 @@ static int
>  _osd_xdr_decode_opaque_cred(struct pnfs_osd_opaque_cred *opaque_cred,
>  			    struct xdr_stream *xdr)
>  {
> -	__be32 *p = xdr_inline_decode(xdr, 1);
> +	__be32 *p = xdr_inline_decode(xdr, sizeof(__be32));
>  
>  	if (!p)
>  		return -EINVAL;


