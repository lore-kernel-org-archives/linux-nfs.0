Return-Path: <SRS0=i0gF=Q6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABCB3C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 02:03:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8296B206C0
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 02:03:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727499AbfBWCDL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 21:03:11 -0500
Received: from szxga05-in.huawei.com ([45.249.212.191]:4260 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725859AbfBWCDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 21:03:11 -0500
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id C02FB8DE733C12FD2559;
        Sat, 23 Feb 2019 10:03:07 +0800 (CST)
Received: from [127.0.0.1] (10.177.33.43) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Sat, 23 Feb 2019
 10:02:59 +0800
Subject: Re: [PATCH] nfs: drop acl cache in __nfs3_proc_setacls
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC:     "yi.zhang@huawei.com" <yi.zhang@huawei.com>,
        "houtao1@huawei.com" <houtao1@huawei.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "zhangxiaoxu5@huawei.com" <zhangxiaoxu5@huawei.com>
References: <20190220072925.103352-1-yangerkun@huawei.com>
 <36623ffc-100a-8abc-451d-0c8a911482b5@huawei.com>
 <687cae4ab7fe14be71994a2d07184af5b69e57ff.camel@hammerspace.com>
From:   yangerkun <yangerkun@huawei.com>
Message-ID: <466731f8-f6fc-1562-32a2-d913830bc93a@huawei.com>
Date:   Sat, 23 Feb 2019 10:00:35 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <687cae4ab7fe14be71994a2d07184af5b69e57ff.camel@hammerspace.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.33.43]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



Trond Myklebust wrote on 2019/2/22 21:51:
> Hi,
> 
> On Fri, 2019-02-22 at 15:35 +0800, yangerkun wrote:
>> Ping?
>>
>> yangerkun wrote on 2019/2/20 15:29:
>>> Since server may call posix_acl_update_mode which can lead acl been
>>> NULL. So,just drop acl cache after rpc_call_sync, and if anyone
>>> want to
>>> use acl, they can get the correct acl by send a msg to server
>>> themselves.
>>> This can fix xfstests generic/099 over nfsv3.
>>>
>>> Signed-off-by: yangerkun <yangerkun@huawei.com>
>>> ---
>>>    fs/nfs/nfs3acl.c | 4 ++--
>>>    1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
>>> index 9fce185..6c07ebc 100644
>>> --- a/fs/nfs/nfs3acl.c
>>> +++ b/fs/nfs/nfs3acl.c
>>> @@ -222,8 +222,8 @@ static int __nfs3_proc_setacls(struct inode
>>> *inode, struct posix_acl *acl,
>>>    	switch (status) {
>>>    		case 0:
>>>    			status = nfs_refresh_inode(inode, fattr);
>>> -			set_cached_acl(inode, ACL_TYPE_ACCESS, acl);
>>> -			set_cached_acl(inode, ACL_TYPE_DEFAULT, dfacl);
>>> +			/* Sever may call posix_acl_update_mode */
>>> +			forget_all_cached_acls(inode);
>>>    			break;
>>>    		case -EPFNOSUPPORT:
>>>    		case -EPROTONOSUPPORT:
>>>
> 
> I've applied the following patch
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=ded52fbe7020a5696b0b0a0fdbf234e37bf16f94
> in order to fix this issue.
> 
> The reason why I prefer that fix is that we're already calling
> nfs_zap_acl_cache(inode) immediately before this switch statement, so
> the call to 'forget_all_cached_acls()' appears redundant.
> 
> Thanks!
>    Trond
> 
Got it! Thanks a lot!

Kun.

