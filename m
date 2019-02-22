Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5972DC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 07:38:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F41E20823
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 07:38:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725906AbfBVHiQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 02:38:16 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:3718 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725824AbfBVHiQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 02:38:16 -0500
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 3869A8779241D2357C17;
        Fri, 22 Feb 2019 15:38:14 +0800 (CST)
Received: from [127.0.0.1] (10.177.33.43) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Fri, 22 Feb 2019
 15:38:03 +0800
Subject: Re: [PATCH] nfs: drop acl cache in __nfs3_proc_setacls
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC:     <houtao1@huawei.com>, <zhangxiaoxu5@huawei.com>,
        <yi.zhang@huawei.com>, <linux-nfs@vger.kernel.org>
References: <20190220072925.103352-1-yangerkun@huawei.com>
From:   yangerkun <yangerkun@huawei.com>
Message-ID: <36623ffc-100a-8abc-451d-0c8a911482b5@huawei.com>
Date:   Fri, 22 Feb 2019 15:35:10 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190220072925.103352-1-yangerkun@huawei.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.33.43]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ping?

yangerkun wrote on 2019/2/20 15:29:
> Since server may call posix_acl_update_mode which can lead acl been
> NULL. So,just drop acl cache after rpc_call_sync, and if anyone want to
> use acl, they can get the correct acl by send a msg to server themselves.
> This can fix xfstests generic/099 over nfsv3.
> 
> Signed-off-by: yangerkun <yangerkun@huawei.com>
> ---
>   fs/nfs/nfs3acl.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> index 9fce185..6c07ebc 100644
> --- a/fs/nfs/nfs3acl.c
> +++ b/fs/nfs/nfs3acl.c
> @@ -222,8 +222,8 @@ static int __nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
>   	switch (status) {
>   		case 0:
>   			status = nfs_refresh_inode(inode, fattr);
> -			set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
> -			set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
> +			/* Sever may call posix_acl_update_mode */
> +			forget_all_cached_acls(inode);
>   			break;
>   		case -EPFNOSUPPORT:
>   		case -EPROTONOSUPPORT:
> 

