Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62268 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab0HTHWR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2010 03:22:17 -0400
Message-ID: <4C6E2CC6.8070208@cn.fujitsu.com>
Date: Fri, 20 Aug 2010 15:20:38 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Server should allow offset larger than LLONG_MAX at commit
 procedure
References: <4C6B9538.2020608@cn.fujitsu.com> <20100819001647.GD18367@fieldses.org> <4C6CA739.5030504@cn.fujitsu.com> <20100819221903.GB9275@fieldses.org>
In-Reply-To: <20100819221903.GB9275@fieldses.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields ŽÊ“¹:
> On Thu, Aug 19, 2010 at 11:38:33AM +0800, Bian Naimeng wrote:
>>
>> J. Bruce Fields ŽÊ“¹:
>>> On Wed, Aug 18, 2010 at 04:09:28PM +0800, Bian Naimeng wrote:
>>>> When offset larger than LLONG_MAX, it's better to sync all the data of file
>>>> than return nfserr_inval.
>>> I believe the current behavior is correct.
>>>
>>> See http://marc.info/?l=linux-nfs&m=128200558207974&w=2 for a pynfs-side
>>> fix.
>>>
>>   Thanks.
>>
>>   But why we must return nfserr_inval at nfs layer, the commitarg.offset and
>>   writearg.offset are the U64 type, i think maybe we should set the vfs as the
>>   authority not nfs for whether the offset is valid when it over 2^63-1.
> 
> Hm, good question.  I took a quick look at vfs_fsync_range() and its
> other callers but couldn't immediately tell whether checking the
> validity of the range is its responsibility or the caller's.
> 
> If you can demonstrate that vfs_fsync_range() takes responsibility for
> the range-checking, then I'd be fine with removing the checks here.
> 

It looks like that vfs_fsync_range has not the range-checking, but i think
vfs_fsync_range should support the function of range-checking.

And NFSv4 write procedure will do the range-checking at rw_verify_area.

-- 
Regards
Bian Naimeng




