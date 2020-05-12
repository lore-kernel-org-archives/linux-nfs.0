Return-Path: <SRS0=SGEM=62=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75B2BC47255
	for <linux-nfs@archiver.kernel.org>; Tue, 12 May 2020 00:21:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5C3E4206D6
	for <linux-nfs@archiver.kernel.org>; Tue, 12 May 2020 00:21:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726415AbgELAVN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 May 2020 20:21:13 -0400
Received: from fieldses.org ([173.255.197.46]:55234 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725854AbgELAVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 May 2020 20:21:13 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id DD4588A6; Mon, 11 May 2020 20:21:12 -0400 (EDT)
Date:   Mon, 11 May 2020 20:21:12 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Xiongfeng Wang <wangxiongfeng2@huawei.com>
Cc:     chuck.lever@oracle.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, davem@davemloft.net, kuba@kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] sunrpc: add missing newline when printing parameter
 'pool_mode' by sysfs
Message-ID: <20200512002112.GA17212@fieldses.org>
References: <1588901580-44687-1-git-send-email-wangxiongfeng2@huawei.com>
 <1588901580-44687-2-git-send-email-wangxiongfeng2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1588901580-44687-2-git-send-email-wangxiongfeng2@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, May 08, 2020 at 09:32:59AM +0800, Xiongfeng Wang wrote:
> When I cat parameter '/sys/module/sunrpc/parameters/pool_mode', it
> displays as follows. It is better to add a newline for easy reading.

Applying for 5.8.  I assume Trond's getting the other patch.

--b.

> 
> [root@hulk-202 ~]# cat /sys/module/sunrpc/parameters/pool_mode
> global[root@hulk-202 ~]#
> 
> Signed-off-by: Xiongfeng Wang <wangxiongfeng2@huawei.com>
> ---
>  net/sunrpc/svc.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 187dd4e..d8ef47f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -88,15 +88,15 @@ struct svc_pool_map svc_pool_map = {
>  	switch (*ip)
>  	{
>  	case SVC_POOL_AUTO:
> -		return strlcpy(buf, "auto", 20);
> +		return strlcpy(buf, "auto\n", 20);
>  	case SVC_POOL_GLOBAL:
> -		return strlcpy(buf, "global", 20);
> +		return strlcpy(buf, "global\n", 20);
>  	case SVC_POOL_PERCPU:
> -		return strlcpy(buf, "percpu", 20);
> +		return strlcpy(buf, "percpu\n", 20);
>  	case SVC_POOL_PERNODE:
> -		return strlcpy(buf, "pernode", 20);
> +		return strlcpy(buf, "pernode\n", 20);
>  	default:
> -		return sprintf(buf, "%d", *ip);
> +		return sprintf(buf, "%d\n", *ip);
>  	}
>  }
>  
> -- 
> 1.7.12.4
