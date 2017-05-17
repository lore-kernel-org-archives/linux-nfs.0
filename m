Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46558 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751789AbdEQPqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 May 2017 11:46:53 -0400
Date: Wed, 17 May 2017 11:46:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Gu Zheng <guzheng1@huawei.com>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org,
        houtao1@huawei.com, Zhaohongjiang <zhaohongjiang@huawei.com>,
        miaoxie@huawei.com, Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: nfs+ext4,can not umount the ext4 mountpoint
Message-ID: <20170517154648.GB30168@fieldses.org>
References: <591AF71F.1040703@huawei.com>
 <20170516174215.GA15232@fieldses.org>
 <591BF94E.9000805@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <591BF94E.9000805@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 17, 2017 at 03:18:38PM +0800, Gu Zheng wrote:
> and now we do not set the crossmnt ,so that we saw is the underlying directory .
> the nfs mount have no relation to ext4 mountpoint, it can be umounted maybe better.
> 
> can we add some limits to let it do not enter the nfsd_cross_mnt() in nfsd_lookup_dentry()if the crossmnt is not set?

If the problem is inability to unmount a filesystem that isn't actually
even exported, then it *might* be addressed by Kinglong Mee's patches:

	http://lkml.kernel.org/r/55ED9899.9010401@gmail.com

I'm not sure what those patches still need--they may just be waiting for
my review.

--b
