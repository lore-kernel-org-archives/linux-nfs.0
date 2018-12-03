Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91DF5C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:36:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 399F82081C
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:36:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 399F82081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725872AbeLCIgk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 03:36:40 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:16070 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725846AbeLCIgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 03:36:40 -0500
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id 0F98028199AE9;
        Mon,  3 Dec 2018 16:36:36 +0800 (CST)
Received: from [127.0.0.1] (10.184.213.217) by DGGEMS413-HUB.china.huawei.com
 (10.3.19.213) with Microsoft SMTP Server id 14.3.408.0; Mon, 3 Dec 2018
 16:36:30 +0800
Subject: Re: [PATCH] nfsd: Return EPERM on utime/utimes/lutimes calls instead
 of EACCESS in some cases
To:     <bfields@fieldses.org>, <jlayton@kernel.org>,
        <linux-nfs@vger.kernel.org>
CC:     <houtao1@huawei.com>, <zhaohongjiang@huawei.com>
References: <1543564290-147370-1-git-send-email-zhengbin13@huawei.com>
From:   "zhengbin (A)" <zhengbin13@huawei.com>
Message-ID: <4e0152c4-bbe9-4246-27ee-bae2fee9129d@huawei.com>
Date:   Mon, 3 Dec 2018 16:36:27 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <1543564290-147370-1-git-send-email-zhengbin13@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.213.217]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

hi, J. Bruce Fields, Jeff Layton

 When you have time, confirm it? thanks

On 2018/11/30 15:51, zhengbin wrote:
> As the man(3) page for utime/utimes/lutimes, EPERM is returned
> when the second parameter of utime/utimes/lutimes is not NULL,
> the caller's effective UID does not match the owner of the file,
> and the caller is not privileged.
> 
> However, in a NFS directory, it will return EACCESS(nfsd_setattr->
> fh_verify->nfsd_permission), This patch fix this.
> 
> Signed-off-by: zhengbin <zhengbin13@huawei.com>
> ---
>  fs/nfsd/vfs.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index eb67098..9824e32 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -396,10 +396,23 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	bool		get_write_count;
>  	bool		size_change = (iap->ia_valid & ATTR_SIZE);
> 
> -	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> +	if (iap->ia_valid & ATTR_SIZE) {
>  		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> -	if (iap->ia_valid & ATTR_SIZE)
>  		ftype = S_IFREG;
> +	}
> +
> +	/*
> +	 * If utimes(2) and friends are called with times not NULL, we should
> +	 * not set NFSD_MAY_WRITE bit. Otherwise fh_verify->nfsd_permission
> +	 * will return EACCESS, when the caller's effective UID does not match
> +	 * the owner of the file, and the caller is not privileged. In this
> +	 * situation, we should return EPERM(notify_change will return this).
> +	 */
> +	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME)) {
> +		accmode |= NFSD_MAY_OWNER_OVERRIDE;
> +		if (!(iap->ia_valid & (ATTR_ATIME_SET | ATTR_MTIME_SET)))
> +			accmode |= NFSD_MAY_WRITE;
> +	}
> 
>  	/* Callers that do fh_verify should do the fh_want_write: */
>  	get_write_count = !fhp->fh_dentry;
> --
> 2.7.4
> 
> 
> .
> 

