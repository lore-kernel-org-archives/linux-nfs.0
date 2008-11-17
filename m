From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 04/51] nfsd: fix file comment in fs/nfsd/nfs4xdr.c
Date: Mon, 17 Nov 2008 15:56:50 +0200
Message-ID: <49217822.70505@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349717-10242-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:14154 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752064AbYKQN4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:56:53 -0500
In-Reply-To: <1226349717-10242-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:41 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 2008-11-12: delete comment instead.
also, for new files the policy today is not to have these
comments at all.

> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index afcdf4b..f7dec05 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1,5 +1,5 @@
>  /*
> - *  fs/nfs/nfs4xdr.c
> + *  fs/nfsd/nfs4xdr.c
>   *
>   *  Server-side XDR for NFSv4
>   *
