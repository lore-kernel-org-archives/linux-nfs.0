Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:58548 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab2HVBKM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 21:10:12 -0400
MIME-Version: 1.0
In-Reply-To: <20120821130458.GD22321@localhost>
References: <1345283402-7889-1-git-send-email-linkinjeon@gmail.com>
	<20120819025724.GC16796@localhost>
	<CAKYAXd83r3RNi3Rn5s3DAEE=34YYbk_hUWcG6R3Zu3JwUw74aA@mail.gmail.com>
	<20120820145032.GA7469@localhost>
	<CAKYAXd9L5Kwj3SEHO=a60c65OXRt73q+-w-Uux6OJ=6Q-3jvYQ@mail.gmail.com>
	<20120821130458.GD22321@localhost>
Date: Wed, 22 Aug 2012 10:10:11 +0900
Message-ID: <CAKYAXd-TTr7KWTpssn1aNrjKCp81=qP-X2RiKhhQ60RJdgA=tg@mail.gmail.com>
Subject: Re: [PATCH 3/3] writeback: add dirty_ratio_time per bdi variable (NFS
 write performance)
From: Namjae Jeon <linkinjeon@gmail.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <namjae.jeon@samsung.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/8/21, Fengguang Wu <fengguang.wu@intel.com>:
> On Tue, Aug 21, 2012 at 03:00:13PM +0900, Namjae Jeon wrote:
>> 2012/8/20, Fengguang Wu <fengguang.wu@intel.com>:
>> > On Mon, Aug 20, 2012 at 09:48:42AM +0900, Namjae Jeon wrote:
>> >> 2012/8/19, Fengguang Wu <fengguang.wu@intel.com>:
>> >> > On Sat, Aug 18, 2012 at 05:50:02AM -0400, Namjae Jeon wrote:
>> >> >> From: Namjae Jeon <namjae.jeon@samsung.com>
>> >> >>
>> >> >> This patch is based on suggestion by Wu Fengguang:
>> >> >> https://lkml.org/lkml/2011/8/19/19
>> >> >>
>> >> >> kernel has mechanism to do writeback as per dirty_ratio and
>> >> >> dirty_background
>> >> >> ratio. It also maintains per task dirty rate limit to keep balance
>> >> >> of
>> >> >> dirty pages at any given instance by doing bdi bandwidth
>> >> >> estimation.
>> >> >>
>> >> >> Kernel also has max_ratio/min_ratio tunables to specify percentage
>> >> >> of
>> >> >> writecache
>> >> >> to control per bdi dirty limits and task throtelling.
>> >> >>
>> >> >> However, there might be a usecase where user wants a writeback
>> >> >> tuning
>> >> >> parameter to flush dirty data at desired/tuned time interval.
>> >> >>
>> >> >> dirty_background_time provides an interface where user can tune
>> >> >> background
>> >> >> writeback start time using /sys/block/sda/bdi/dirty_background_time
>> >> >>
>> >> >> dirty_background_time is used alongwith average bdi write bandwidth
>> >> >> estimation
>> >> >> to start background writeback.
>> >> >
>> >> > Here lies my major concern about dirty_background_time: the write
>> >> > bandwidth estimation is an _estimation_ and will sure become wildly
>> >> > wrong in some cases. So the dirty_background_time implementation
>> >> > based
>> >> > on it will not always work to the user expectations.
>> >> >
>> >> > One important case is, some users (eg. Dave Chinner) explicitly take
>> >> > advantage of the existing behavior to quickly create & delete a big
>> >> > 1GB temp file without worrying about triggering unnecessary IOs.
>> >> >
>> >> Hi. Wu.
>> >> Okay, I have a question.
>> >>
>> >> If making dirty_writeback_interval per bdi to tune short interval
>> >> instead of background_time, We can get similar performance
>> >> improvement.
>> >> /sys/block/<device>/bdi/dirty_writeback_interval
>> >> /sys/block/<device>/bdi/dirty_expire_interval
>> >>
>> >> NFS write performance improvement is just one usecase.
>> >>
>> >> If we can set interval/time per bdi,  other usecases will be created
>> >> by applying.
>> >
>> > Per-bdi interval/time tunables, if there comes such a need, will in
>> > essential be for data caching and safety. If turning them into some
>> > requirement for better performance, the users will potential be
>> > stretched on choosing the "right" value for balanced data cache,
>> > safety and performance.  Hmm, not a comfortable prospection.
>> Hi Wu.
>> First, Thanks for shared information.
>>
>> I change writeback interval on NFS server only.
>
> OK..sorry for missing that part!
>
>> I think that this does not affect data cache/page behaviour(caching)
>> change on NFS client. NFS client will start sending write requests as
>> per default NFS/writeback logic. So, no change in NFS client data
>> caching behaviour.
>>
>> Also, on NFS server it does not make change in system-wide caching
>> behaviour. It only modifies caching/writeback behaviour of a
>> particular “bdi” on NFS server so that NFS client could see better
>> WRITE speed.
>
> But would you default to dirty_background_time=0, where the special
> value 0 means no change of the original behavior? That will address
> David's very reasonable concern. Otherwise quite a few users are going
> to be surprised by the new behavior after upgrading kernel.
Hi. Wu.
Okay, I will resend v2 patch included your
comment(dirty_background_time=0 at default)
Thanks a lot.

>
>> I will share several performancetest results as Dave's opinion.
>>
>> >
>> >> >The numbers are impressive! FYI, I tried another NFS specific
>> >> > approach
>> >> >to avoid big NFS COMMITs, which achieved similar performance gains:
>> >>
>> >> >nfs: writeback pages wait queue
>> >> >https://lkml.org/lkml/2011/10/20/235
>> This patch looks client side optimization to me.(need to check more)
>
> Yes.
>
>> Do we need the optimization of server side as Bruce's opinion ?
>
> Sure.
>
> Thanks,
> Fengguang
>
