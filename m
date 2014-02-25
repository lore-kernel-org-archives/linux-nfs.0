Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:46532 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbaBYSiH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Feb 2014 13:38:07 -0500
Received: by mail-ie0-f174.google.com with SMTP id as1so711687iec.33
        for <linux-nfs@vger.kernel.org>; Tue, 25 Feb 2014 10:38:07 -0800 (PST)
Message-ID: <530CE306.9050600@primarydata.com>
Date: Tue, 25 Feb 2014 10:37:58 -0800
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
CC: stable@vger.kernel.org
Subject: Re: [PATCH 1/5] nfsd4: buffer-length check for SUPPATTR_EXCLCREAT
References: <1393279727-29437-1-git-send-email-bfields@redhat.com> <1393279727-29437-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1393279727-29437-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 02/24/2014 02:08 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
>
> This was an omission from 8c18f2052e756e7d5dea712fc6e7ed70c00e8a39
> "nfsd41: SUPPATTR_EXCLCREAT attribute".
>
> Cc: stable@vger.kernel.org
> Cc: Benny Halevy <bhalevy@primarydata.com>

Ack.
Thanks for fixing!

Benny

> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 63f2395..668bfe1 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2483,6 +2483,8 @@ out_acl:
>  			goto out;
>  	}
>  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
> +		if ((buflen -= 16) < 0)
> +			goto out_resource;
>  		WRITE32(3);
>  		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
>  		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD1);

