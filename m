Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4144DC43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 01:13:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D28B20851
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 01:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D28B20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726539AbeK1MNA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 07:13:00 -0500
Received: from p3plsmtpa08-10.prod.phx3.secureserver.net ([173.201.193.111]:42853
        "EHLO p3plsmtpa08-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726567AbeK1MNA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 07:13:00 -0500
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id RoPigkD5CSuJQRoPigkqMu; Tue, 27 Nov 2018 18:13:14 -0700
Subject: Re: [PATCH v1] svcrdma: Optimize the logic that selects the R_key to
 invalidate
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20181127161016.6997.69002.stgit@klimt.1015granger.net>
 <14c5a1e8-115b-a58b-7c65-4e207caf3d33@talpey.com>
 <0E1C5F18-C0E8-43D2-AF21-B6DCC84E302C@oracle.com>
 <45f70f31-997b-ab1e-9430-57f2e0d78318@talpey.com>
 <79BDA67D-4B6E-423F-BAF3-ADE5E703B5BC@oracle.com>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <85f9cad6-9833-a193-44d0-b0397cafbcd7@talpey.com>
Date:   Tue, 27 Nov 2018 20:13:14 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <79BDA67D-4B6E-423F-BAF3-ADE5E703B5BC@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfIBj4izDIPcvupN4d8hXVdNLsWZGd93EtfwfvINLqQ61b1B8rSB/qpz05jWT/YH9pQqcnPCtSxderquRgITc7+XBrml4qg+rE2HOJ8GOVNuCFQwVq3Q4
 HCfJUHrFe0nsw9VSg27NElB/1Syh4wepwmh1aiYbhDV4JXumsy7OSeUhBrRIffdOBmQu050nS7UV3judMy/0kGIES/s9EYOGcwl3cT7kor+/MFEmc6XlPOP/
 PDqdIXREo5W68BpPXjLS2Q==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/27/2018 5:23 PM, Chuck Lever wrote:
> 
> 
>> On Nov 27, 2018, at 4:30 PM, Tom Talpey <tom@talpey.com> wrote:
>>
>> On 11/27/2018 4:21 PM, Chuck Lever wrote:
>>>> On Nov 27, 2018, at 4:16 PM, Tom Talpey <tom@talpey.com> wrote:
>>>>
>>>> On 11/27/2018 11:11 AM, Chuck Lever wrote:
>>>>> o Select the R_key to invalidate while the CPU cache still contains
>>>>>    the received RPC Call transport header, rather than waiting until
>>>>>    we're about to send the RPC Reply.
>>>>> o Choose Send With Invalidate if there is exactly one distinct R_key
>>>>>    in the received transport header. If there's more than one, the
>>>>>    client will have to perform local invalidation after it has
>>>>>    already waited for remote invalidation.
>>>>
>>>> What's the reason for remote-invalidating only if exactly one
>>>> region is targeted? It seems valuable to save the client the work,
>>>> no matter how many regions are used.
>>> Because remote invalidation delays the Receive completion.
>>
>> Well yes, but the invalidations have to happen before the reply is
>> processed, and remote invalidation saves a local work request plus
>> its completion.
> 
> That is true only if remote invalidation can knock down all the
> R_keys for that RPC. If there's more than one R_key for that RPC,
> a local invalidation is needed anyway, and there's no savings but
> rather there is a cost of the extra latency of waiting twice.
> 
> A couple of details to note:
> - remote invalidation is only available with FRWR, which
>    invalidates asynchronously
> - a smart FRWR client implementation will post a chain of LOCAL
>    INV WRs, then wait for the last one to signal completion. That's
>    just one doorbell, one interrupt, and one context switch no
>    matter how many LOCAL INV WRs are needed.
> 
> So if the client still has to do even one local invalidation, it's
> not worth the trouble to remotely invalidate.

I still don't agree about "not worth" it, but it's a choice.

Just a couple of other notes:

>> Have you measured the difference?
> 
> Yes, as reported in the patch description. Perhaps I can include
> some interesting iozone results.

I didn't see anything about this in the patch description, but I was
not arguing for including this kind of detail, just whether you had
actually measured it. I'm interested in that, btw.

> This behavior seems to be a typical feature of most recent hardware.
> I suspect there's some locking of the hardware Send queue to handle
> RI that contends with actual posted WRs from the host.

That would be really bad. Have you reported this to the vendors?

> With cards that have a shallow FR depth, multiple MRs/R_keys are
> required to register a single 1MB NFS READ or WRITE. Here's where
> squelching remote invalidation really pays off.

Sure, but such a bandwidth-dominated workload isn't very interesting
performance-wise. With 1MB ops I would expect you to be wire-limited,
right?

>> I think it would be best to capture some or all of this
>> explanation in the commit message, in any case.
> 
> You mean you want my patch description to explain _why_ ? ;-)

Sort of. My belief is that this decision represents a micro-optimization
and is unlikely to be forever true. More significantly, it's not a
bug fix or correctness issue. So, capturing the reasoning behind
it is useful for the future, in case someone thinks to unwind it.

Tom.
