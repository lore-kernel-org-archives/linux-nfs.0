Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53873 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751087AbbBBRIr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 12:08:47 -0500
Message-ID: <54CFAF1C.4050104@fb.com>
Date: Mon, 2 Feb 2015 10:08:44 -0700
From: Jens Axboe <axboe@fb.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Al Viro <viro@ZenIV.linux.org.uk>
CC: David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
        <linux-mtd@lists.infradead.org>, <linux-nfs@vger.kernel.org>,
        <ceph-devel@vger.kernel.org>
Subject: Re: backing_dev_info cleanups & lifetime rule fixes V2
References: <1421228561-16857-1-git-send-email-hch@lst.de> <54BEC3C2.7080906@fb.com> <20150201063116.GP29656@ZenIV.linux.org.uk> <20150202080635.GB9851@lst.de>
In-Reply-To: <20150202080635.GB9851@lst.de>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/02/2015 01:06 AM, Christoph Hellwig wrote:
> On Sun, Feb 01, 2015 at 06:31:16AM +0000, Al Viro wrote:
>> And at that point we finally can make sb_lock and super_blocks static in
>> fs/super.c.  Do you want that in your tree, or would you rather have it
>> done via vfs.git during the merge window after your tree goes in?  It's
>> as trivial as this:
>>
>> Make super_blocks and sb_lock static
>>
>> The only user outside of fs/super.c is gone now
>>
>> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> I'd say merge it through the block tree..
> 
> Acked-by: Christoph Hellwig <hch@lst.de>

Added to for-3.20/bdi


-- 
Jens Axboe

