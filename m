Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:6356 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934169AbdERLG3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2017 07:06:29 -0400
Subject: Re: nfs+ext4,can not umount the ext4 mountpoint
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <591AF71F.1040703@huawei.com>
 <20170516174215.GA15232@fieldses.org> <591BF94E.9000805@huawei.com>
 <20170517154648.GB30168@fieldses.org>
CC: <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        <houtao1@huawei.com>, Zhaohongjiang <zhaohongjiang@huawei.com>,
        <miaoxie@huawei.com>, Kinglong Mee <kinglongmee@gmail.com>
From: Gu Zheng <guzheng1@huawei.com>
Message-ID: <591D7E95.5030109@huawei.com>
Date: Thu, 18 May 2017 18:59:33 +0800
MIME-Version: 1.0
In-Reply-To: <20170517154648.GB30168@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

to J. Bruce Fields:
thanks for your supports.
to Kinglong Mee:
I warried about how to modify for supporting the expected unmount.
It is helpful to me after i saw the patchs,but it felt a little unreasonably in bellow scene:
if a filesystem is exported and i am in the mounted directory on client,the fs also can be umounted on server.


best wishes!


在 2017/5/17 23:46, J. Bruce Fields 写道:
> On Wed, May 17, 2017 at 03:18:38PM +0800, Gu Zheng wrote:
>> and now we do not set the crossmnt ,so that we saw is the underlying directory .
>> the nfs mount have no relation to ext4 mountpoint, it can be umounted maybe better.
>>
>> can we add some limits to let it do not enter the nfsd_cross_mnt() in nfsd_lookup_dentry()if the crossmnt is not set?
>
> If the problem is inability to unmount a filesystem that isn't actually
> even exported, then it *might* be addressed by Kinglong Mee's patches:
>
> 	http://lkml.kernel.org/r/55ED9899.9010401@gmail.com
>
> I'm not sure what those patches still need--they may just be waiting for
> my review.
>
> --b
>
> .
>

