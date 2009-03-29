From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 24/46] NFS: fix decode_fs_locations_maxsz
Date: Sun, 29 Mar 2009 13:40:17 -0400
Message-ID: <1238348417.23986.1.camel@heimdal.trondhjem.org>
References: <49ADBD04.2090002@panasas.com>
	 <1236124672-3656-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbZC2RlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Mar 2009 13:41:04 -0400
In-Reply-To: <1236124672-3656-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-03-03 at 16:57 -0700, Benny Halevy wrote:
> need to take into account the getattr reply.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index b60dc56..0e01660 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -239,7 +239,7 @@ static int nfs4_stat_to_errno(int);
>  #define encode_fs_locations_maxsz \
>                                 (encode_getattr_maxsz)
>  #define decode_fs_locations_maxsz \
> -                               (0)
> +                               (decode_getattr_maxsz)

This is a bit excessive. If you look at xdr_enc_fs_locations, you'll see
that this just needs to decode the OP_GETATTR + status. All the data
goes into the page.

>  #define NFS4_enc_compound_sz   (1024)  /* XXX: large enough? */
>  #define NFS4_dec_compound_sz   (1024)  /* XXX: large enough? */
>  #define NFS4_enc_read_sz       (compound_encode_hdr_maxsz + \
> --
> 1.6.1.3
> 
> 
> 
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
