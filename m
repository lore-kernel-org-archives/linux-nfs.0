Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B180C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 01:04:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 16CC220850
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 01:04:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16CC220850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726082AbeLEBEe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 20:04:34 -0500
Received: from szxga06-in.huawei.com ([45.249.212.32]:47721 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725979AbeLEBEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 20:04:34 -0500
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
        by Forcepoint Email with ESMTP id A716487AAD095;
        Wed,  5 Dec 2018 09:04:31 +0800 (CST)
Received: from [127.0.0.1] (10.184.213.217) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Wed, 5 Dec 2018
 09:04:24 +0800
Subject: Re: [PATCH] nfsd: Return EPERM on utime/utimes/lutimes calls instead
 of EACCESS in some cases
To:     "J. Bruce Fields" <bfields@fieldses.org>
CC:     <jlayton@kernel.org>, <linux-nfs@vger.kernel.org>,
        <houtao1@huawei.com>, <zhaohongjiang@huawei.com>
References: <1543564290-147370-1-git-send-email-zhengbin13@huawei.com>
 <4e0152c4-bbe9-4246-27ee-bae2fee9129d@huawei.com>
 <20181204201357.GC3903@fieldses.org>
From:   "zhengbin (A)" <zhengbin13@huawei.com>
Message-ID: <e3073b92-1eab-78f5-09ae-629e6496fac4@huawei.com>
Date:   Wed, 5 Dec 2018 09:04:22 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20181204201357.GC3903@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.213.217]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

thanks,
>>> As the man(3) page for utime/utimes/lutimes, EPERM is returned

-------->this should be As the man page for utime/utimes/lutimes, my little mistake. utime/utimes are man(2), lutimes is man(3)

I send v2 patch?Or when you apply, help modify it?

On 2018/12/5 4:13, J. Bruce Fields wrote:
> On Mon, Dec 03, 2018 at 04:36:27PM +0800, zhengbin (A) wrote:
>> hi, J. Bruce Fields, Jeff Layton
>>
>>  When you have time, confirm it? thanks
> 
> Sorry for the delay.
> 
> The patch looks good to me.
> 
> As far as I can tell, we've done this forever.  And I'm a little worried
> about changing such long-standing behavior, but I think you're right.
> 
> So, applying for for 4.21.
> 
> --b.
> 
>> On 2018/11/30 15:51, zhengbin wrote:
>>> As the man(3) page for utime/utimes/lutimes, EPERM is returned
>>> when the second parameter of utime/utimes/lutimes is not NULL,
>>> the caller's effective UID does not match the owner of the file,
>>> and the caller is not privileged.
>>>
>>> However, in a NFS directory, it will return EACCESS(nfsd_setattr->
>>> fh_verify->nfsd_permission), This patch fix this.
>>>
>>> Signed-off-by: zhengbin <zhengbin13@huawei.com>
>>> ---
>>>  fs/nfsd/vfs.c | 17 +++++++++++++++--
>>>  1 file changed, 15 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>> index eb67098..9824e32 100644
>>> --- a/fs/nfsd/vfs.c
>>> +++ b/fs/nfsd/vfs.c
>>> @@ -396,10 +396,23 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>>>  	bool		get_write_count;
>>>  	bool		size_change = (iap->ia_valid & ATTR_SIZE);
>>>
>>> -	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
>>> +	if (iap->ia_valid & ATTR_SIZE) {
>>>  		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
>>> -	if (iap->ia_valid & ATTR_SIZE)
>>>  		ftype = S_IFREG;
>>> +	}
>>> +
>>> +	/*
>>> +	 * If utimes(2) and friends are called with times not NULL, we should
>>> +	 * not set NFSD_MAY_WRITE bit. Otherwise fh_verify->nfsd_permission
>>> +	 * will return EACCESS, when the caller's effective UID does not match
>>> +	 * the owner of the file, and the caller is not privileged. In this
>>> +	 * situation, we should return EPERM(notify_change will return this).
>>> +	 */
>>> +	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME)) {
>>> +		accmode |= NFSD_MAY_OWNER_OVERRIDE;
>>> +		if (!(iap->ia_valid & (ATTR_ATIME_SET | ATTR_MTIME_SET)))
>>> +			accmode |= NFSD_MAY_WRITE;
>>> +	}
>>>
>>>  	/* Callers that do fh_verify should do the fh_want_write: */
>>>  	get_write_count = !fhp->fh_dentry;
>>> --
>>> 2.7.4
>>>
>>>
>>> .
>>>
> 
> .
> 

