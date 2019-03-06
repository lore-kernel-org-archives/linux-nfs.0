Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F8EC10F00
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 14:58:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8153620840
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 14:58:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727795AbfCFO6t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 09:58:49 -0500
Received: from fieldses.org ([173.255.197.46]:41624 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726934AbfCFO6t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 09:58:49 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 4A2CEA9F; Wed,  6 Mar 2019 09:58:49 -0500 (EST)
Date:   Wed, 6 Mar 2019 09:58:49 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Yihao Wu <wuyihao@linux.alibaba.com>
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org, Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: Re: [PATCH] nfsd: fix wrong check in write_v4_end_grace()
Message-ID: <20190306145849.GA2426@fieldses.org>
References: <22af6507-782d-d2fb-77f7-455dad27697f@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22af6507-782d-d2fb-77f7-455dad27697f@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 09:47:14PM +0800, Yihao Wu wrote:
> >From 04ddefd79a5cd410d65b7a30593ac915b9fab687 Mon Sep 17 00:00:00 2001
> From: Yihao Wu <wuyihao@linux.alibaba.com>
> Date: Wed, 6 Mar 2019 21:03:50 +0800
> Subject: [PATCH] nfsd: fix wrong check in write_v4_end_grace()
> 
> Commit 62a063b8e7d1 "nfsd4: fix crash on writing v4_end_grace before
> nfsd startup" is trying to fix a NULL dereference issue, but it
> mistakenly checks if the nfsd server is started. So fix it.

Applied, thanks!--b.

> 
> Fixes: 62a063b8e7d1 "nfsd4: fix crash on writing v4_end_grace before nfsd startup"
> Cc: stable@vger.kernel.org
> Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
> Signed-off-by: Yihao Wu <wuyihao@linux.alibaba.com>
> ---
>  fs/nfsd/nfsctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 72a7681..f2feb2d 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1126,7 +1126,7 @@ static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
>  		case 'Y':
>  		case 'y':
>  		case '1':
> -			if (nn->nfsd_serv)
> +			if (!nn->nfsd_serv)
>  				return -EBUSY;
>  			nfsd4_end_grace(nn);
>  			break;
> -- 
> 1.8.3.1
