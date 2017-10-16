Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:48364 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdJPNeV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 09:34:21 -0400
MIME-Version: 1.0
Reply-To: jglauber@cavium.com
In-Reply-To: <1507744197.50316.3.camel@primarydata.com>
References: <20171009181738.GA30680@red-moon> <1507573931.3516.3.camel@primarydata.com>
 <20171010140336.GI3301751@devbig577.frc2.facebook.com> <1507654135.4442.4.camel@primarydata.com>
 <20171010171919.GO3301751@devbig577.frc2.facebook.com> <1507744197.50316.3.camel@primarydata.com>
From: Jan Glauber <jan.glauber@gmail.com>
Date: Mon, 16 Oct 2017 15:34:20 +0200
Message-ID: <CAEiAFz00xmDPSRi+EPpYwnJPkzd1E2mDc-afDnpqtiOgKFHscQ@mail.gmail.com>
Subject: Re: net/sunrpc: v4.14-rc4 lockdep warning
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "tj@kernel.org" <tj@kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "lorenzo.pieralisi@arm.com" <lorenzo.pieralisi@arm.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

is there a patch available for this issue? I'm running into with
4.14-rc5 on my ARM64 board.

thanks, Jan

2017-10-11 19:49 GMT+02:00 Trond Myklebust <trondmy@primarydata.com>:
> On Tue, 2017-10-10 at 10:19 -0700, tj@kernel.org wrote:
>> Hello,
>>
>> On Tue, Oct 10, 2017 at 04:48:57PM +0000, Trond Myklebust wrote:
>> > Thanks for the explanation. What I'm not really understanding here
>> > though, is how the work item could be queued at all. We have a
>> > wait_on_bit_lock() in xprt_destroy() that should mean the xprt-
>> > > task_cleanup work item has completed running, and that it cannot
>> > > be
>> >
>> > requeued.
>> >
>> > Is there a possibility that the flush_queue() might be triggered
>> > despite the work item not being queued?
>>
>> Yeah, for sure.  The lockdep annotations don't distinguish those
>> cases and assume the worst case.
>>
>
> OK. Let's just remove that call to cancel_work_sync() then. As I said,
> it should be redundant due to the wait_on_bit_lock().
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
