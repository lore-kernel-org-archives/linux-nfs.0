Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:47948 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab2HTAsn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Aug 2012 20:48:43 -0400
MIME-Version: 1.0
In-Reply-To: <20120819025724.GC16796@localhost>
References: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
	<20120819025724.GC16796@localhost>
Date: Mon, 20 Aug 2012 09:48:42 +0900
Message-ID: <CAKYAXd83r3RNi3Rn5s3DAEE=34YYbk_hUWcG6R3Zu3JwUw74aA@mail.gmail.com>
Subject: Re: [PATCH 3/3] writeback: add dirty_ratio_time per bdi variable (NFS
 write performance)
From: Namjae Jeon <linkinjeon@gmail.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <namjae.jeon@samsung.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/8/19, Fengguang Wu <fengguang.wu@intel.com>:
> On Sat, Aug 18, 2012 at 05:50:02AM -0400, Namjae Jeon wrote:
>> From: Namjae Jeon <namjae.jeon@samsung.com>
>>
>> This patch is based on suggestion by Wu Fengguang:
>> https://lkml.org/lkml/2011/8/19/19
>>
>> kernel has mechanism to do writeback as per dirty_ratio and
>> dirty_background
>> ratio. It also maintains per task dirty rate limit to keep balance of
>> dirty pages at any given instance by doing bdi bandwidth estimation.
>>
>> Kernel also has max_ratio/min_ratio tunables to specify percentage of
>> writecache
>> to control per bdi dirty limits and task throtelling.
>>
>> However, there might be a usecase where user wants a writeback tuning
>> parameter to flush dirty data at desired/tuned time interval.
>>
>> dirty_background_time provides an interface where user can tune
>> background
>> writeback start time using /sys/block/sda/bdi/dirty_background_time
>>
>> dirty_background_time is used alongwith average bdi write bandwidth
>> estimation
>> to start background writeback.
>
> Here lies my major concern about dirty_background_time: the write
> bandwidth estimation is an _estimation_ and will sure become wildly
> wrong in some cases. So the dirty_background_time implementation based
> on it will not always work to the user expectations.
>
> One important case is, some users (eg. Dave Chinner) explicitly take
> advantage of the existing behavior to quickly create & delete a big
> 1GB temp file without worrying about triggering unnecessary IOs.
>
Hi. Wu.
Okay, I have a question.

If making dirty_writeback_interval per bdi to tune short interval
instead of background_time, We can get similar performance
improvement.
/sys/block/<device>/bdi/dirty_writeback_interval
/sys/block/<device>/bdi/dirty_expire_interval

NFS write performance improvement is just one usecase.

If we can set interval/time per bdi,  other usecases will be created
by applying.

How do you think ?

>The numbers are impressive! FYI, I tried another NFS specific approach
>to avoid big NFS COMMITs, which achieved similar performance gains:

>nfs: writeback pages wait queue
>https://lkml.org/lkml/2011/10/20/235

Thanks.
