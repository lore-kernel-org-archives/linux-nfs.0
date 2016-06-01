Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35313 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbcFAU7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2016 16:59:24 -0400
Received: by mail-io0-f194.google.com with SMTP id k19so4097419ioi.2
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2016 13:59:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F693F912-2BA0-4899-A73C-65CB7536B090@primarydata.com>
References: <CAN-5tyFXzH+Je8Th_irarJtBb+9QziFj8p7xH0NRLupOsTYBrw@mail.gmail.com>
	<F693F912-2BA0-4899-A73C-65CB7536B090@primarydata.com>
Date: Wed, 1 Jun 2016 16:59:23 -0400
Message-ID: <CAN-5tyEdttEMqepHWmd-KgUcH-azbnko4QJsVuwQha=GSVgzoA@mail.gmail.com>
Subject: Re: open_downgrade use
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 1, 2016 at 4:41 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> You are misreading what I wrote. Your test should indeed give rise to an
> OPEN_DOWNGRADE (unless there is a delegation involved). The code that was
> misbehaving and that was fixed by the patch was triggering an OPEN_DOWNGRADE
> from a stateid that had only been opened for RW.

I see. With this patch, the upstream code no longer sends an
OPEN_DOWNGRADE. I will investigate why then as it seems like a bug.

>
>
> On 6/1/16, 16:31, "linux-nfs-owner@vger.kernel.org on behalf of Olga
> Kornievskaia" <linux-nfs-owner@vger.kernel.org on behalf of aglo@umich.edu>
> wrote:
>
>>I'm failing to think of what can trigger an open_downgrade?
>>I thought the following example should trigger an open downgrade:
>>
>>fd0 = open(foo, RDRW) -- should be open on the wire for "both"
>>fd1 = open(foo, RDONLY) -- should be open on the wire for "read"
>>close(fd0) -- should trigger an open_downgrade
>>read(fd1)
>>close(fd1)
>>
>>However this commit says that it's not allowed by the spec.
>>
>>commit cd9288ffaea4359d5cfe2b8d264911506aed26a4
>>Author: Trond Myklebust <trond.myklebust@primarydata.com>
>>Date: Thu Sep 18 11:51:32 2014 -0400
>>
>> NFSv4: Fix another bug in the close/open_downgrade code
>>
>> James Drew reports another bug whereby the NFS client is now sending
>> an OPEN_DOWNGRADE in a situation where it should really have sent a
>> CLOSE: the client is opening the file for O_RDWR, but then trying to
>> do a downgrade to O_RDONLY, which is not allowed by the NFSv4 spec.
>>
>> Reported-by: James Drews <drews@engr.wisc.edu>
>> Link: http://lkml.kernel.org/r/541AD7E5.8020409@engr.wisc.edu
>> Fixes: aee7af356e15 (NFSv4: Fix problems with close in the presence...)
>> Cc: stable@vger.kernel.org # 2.6.33+
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>
>>If RDWR to RDONLY isn't allowed then why do we have OPEN_DOWNGRADE at all?
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>
>
> Disclaimer
>
> The information contained in this communication from the sender is
> confidential. It is intended solely for use by the recipient and others
> authorized to receive it. If you are not the recipient, you are hereby
> notified that any disclosure, copying, distribution or taking action in
> relation of the contents of this information is strictly prohibited and may
> be unlawful.
