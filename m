Return-Path: <SRS0=3jA8=4X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA0E5C3F2D2
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Mar 2020 02:14:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 971262073D
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Mar 2020 02:14:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726682AbgCFCOJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 5 Mar 2020 21:14:09 -0500
Received: from szxga05-in.huawei.com ([45.249.212.191]:11175 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726317AbgCFCOJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Mar 2020 21:14:09 -0500
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 3BCD9F2B0A53B14436A0;
        Fri,  6 Mar 2020 10:14:06 +0800 (CST)
Received: from [127.0.0.1] (10.173.223.234) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Fri, 6 Mar 2020
 10:14:04 +0800
Subject: Re: [PATCH] NFSD: Fix NFS server build errors
To:     Chuck Lever <chuck.lever@oracle.com>, <bfields@fieldses.org>,
        <kolga@netapp.com>
References: <20200305233433.14530.61315.stgit@klimt.1015granger.net>
CC:     <linux-nfs@vger.kernel.org>
From:   Yuehaibing <yuehaibing@huawei.com>
Message-ID: <631f52a1-b557-9137-0a7c-f493ac3339af@huawei.com>
Date:   Fri, 6 Mar 2020 10:14:03 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.2.0
MIME-Version: 1.0
In-Reply-To: <20200305233433.14530.61315.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.173.223.234]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2020/3/6 7:38, Chuck Lever wrote:
> yuehaibing@huawei.com reports the following build errors arise when
> CONFIG_NFSD_V4_2_INTER_SSC is set and the NFS client is not built
> into the kernel:
> 
> fs/nfsd/nfs4proc.o: In function `nfsd4_do_copy':
> nfs4proc.c:(.text+0x23b7): undefined reference to `nfs42_ssc_close'
> fs/nfsd/nfs4proc.o: In function `nfsd4_copy':
> nfs4proc.c:(.text+0x5d2a): undefined reference to `nfs_sb_deactive'
> fs/nfsd/nfs4proc.o: In function `nfsd4_do_async_copy':
> nfs4proc.c:(.text+0x61d5): undefined reference to `nfs42_ssc_open'
> nfs4proc.c:(.text+0x6389): undefined reference to `nfs_sb_deactive'
> 
> The new inter-server copy code invokes client functions. Until the
> NFS server has infrastructure to load the appropriate NFS client
> modules to handle inter-server copy requests, let's constrain the
> way this feature is built.
> 
> Reported-by: YueHaibing <yuehaibing@huawei.com>
> Fixes: ce0887ac96d3 ("NFSD add nfs4 inter ssc to nfsd4_copy")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Yue - does this work for you? The dependency is easier for me to
> understand.

It works for me.

Tested-by: YueHaibing <yuehaibing@huawei.com> # build-tested
> 
> Bruce and Olga - OK with this temporary solution?
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index f368f3215f88..99d2cae91bd6 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -136,7 +136,7 @@ config NFSD_FLEXFILELAYOUT
>  
>  config NFSD_V4_2_INTER_SSC
>  	bool "NFSv4.2 inter server to server COPY"
> -	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2
> +	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2 && NFS_FS=y
>  	help
>  	  This option enables support for NFSv4.2 inter server to
>  	  server copy where the destination server calls the NFSv4.2
> 
> 
> 

