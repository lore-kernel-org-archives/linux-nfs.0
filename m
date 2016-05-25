Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:46978 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbcEYPIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 11:08:42 -0400
Date: Wed, 25 May 2016 17:08:39 +0200
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/4] nfsd: flex file device id encoding will need the
	server addres
Message-ID: <20160525150839.GB27535@lst.de>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com> <1464152979-103988-2-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464152979-103988-2-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index de1ff1d..b28e45b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1270,6 +1270,7 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
>  	nfserr = nfs_ok;
>  	if (gdp->gd_maxcount != 0) {
>  		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb,
> +					rqstp,
>  					cstate->session->se_client, gdp);

Can you reindent the code so that the cstate->session->se_client argument
goes onto the same line as rqstp?

Otherwise this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>
