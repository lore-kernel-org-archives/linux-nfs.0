From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: Keep index within mnt_errtbl[]
Date: Mon, 13 Jul 2009 08:59:40 -0400
Message-ID: <1247489980.25140.4.camel@heimdal.trondhjem.org>
References: <4A5A70CD.2030909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4748 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755574AbZGMNAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2009 09:00:37 -0400
In-Reply-To: <4A5A70CD.2030909@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-13 at 01:25 +0200, Roel Kluin wrote:
> Ensure that index i remains within array mnt_errtbl[] and mnt3_errtbl[].
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index 38ef9ea..8b9affc 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -258,7 +258,7 @@ static int decode_status(struct xdr_stream *xdr, struct mountres *res)
>  		return -EIO;
>  	status = ntohl(*p);
>  
> -	for (i = 0; i <= ARRAY_SIZE(mnt_errtbl); i++) {
> +	for (i = 0; i < ARRAY_SIZE(mnt_errtbl); i++) {
>  		if (mnt_errtbl[i].status == status) {
>  			res->errno = mnt_errtbl[i].errno;
>  			return 0;
> @@ -309,7 +309,7 @@ static int decode_fhs_status(struct xdr_stream *xdr, struct mountres *res)
>  		return -EIO;
>  	status = ntohl(*p);
>  
> -	for (i = 0; i <= ARRAY_SIZE(mnt3_errtbl); i++) {
> +	for (i = 0; i < ARRAY_SIZE(mnt3_errtbl); i++) {
>  		if (mnt3_errtbl[i].status == status) {
>  			res->errno = mnt3_errtbl[i].errno;
>  			return 0;

Yup. Good catch!

   Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
