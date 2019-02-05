Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCCF5C282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:50:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 922C920844
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 12:50:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726742AbfBEMu6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 07:50:58 -0500
Received: from foss.arm.com ([217.140.101.70]:40984 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725947AbfBEMu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 07:50:58 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A396480D;
        Tue,  5 Feb 2019 04:50:57 -0800 (PST)
Received: from [10.1.197.50] (e120937-lin.cambridge.arm.com [10.1.197.50])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 079603F675;
        Tue,  5 Feb 2019 04:50:56 -0800 (PST)
Subject: Re: [aarch64] refcount_t: use-after-free in NFS with 64k pages
From:   Cristian Marussi <cristian.marussi@arm.com>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     Punit Agrawal <punit.agrawal@arm.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <c8b0e53b-eccf-5914-af8d-ee47dccd3bcd@arm.com>
 <87va5yvubk.fsf@e105922-lin.cambridge.arm.com>
 <abf58cfc-a575-cb36-47a1-b1135f080362@arm.com>
 <65CE8FC5-3ADB-4E61-8127-70B979B037A0@redhat.com>
 <e99fd27b-9e60-22fc-af6b-da93b0e0ca0f@arm.com>
 <9C25D1F9-3A25-4CF3-822E-CE25829642D9@redhat.com>
 <fe7fb2ad-de9a-69a2-bd0e-9492e52b1be7@arm.com>
Message-ID: <25cd3e8d-18e2-7158-d994-224d2a14b09e@arm.com>
Date:   Tue, 5 Feb 2019 12:50:55 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <fe7fb2ad-de9a-69a2-bd0e-9492e52b1be7@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi

On 05/02/2019 12:37, Cristian Marussi wrote:
> Hi
> 
> On 05/02/2019 12:14, Benjamin Coddington wrote:
>> On 5 Feb 2019, at 7:10, Cristian Marussi wrote:
>>
>>> Hi Ben
>>>
>>> On 05/02/2019 11:53, Benjamin Coddington wrote:
>>>> Hello Cristian and Punit,
>>>>
>>>> Did you ever get to the bottom of this one?  We just saw this on one 
>>>> run
>>>> of our 4.18.0-era ppc64le, and I'm wondering if we ever found the 
>>>> root
>>>> cause.
>>>
>>> unfortunately I stopped working actively on finding the root cause, 
>>> since I've
>>> found a viable workaround that let us unblock our broken LTP runs.
>>>
>>> Setting wsize=65536 in NFS bootparams completely solves the issue with 
>>> 64k pages
>>> (and does NOT break 4k either :D): this confirmed my hyp that there is 
>>> some sort
>>> of race when accounting refcounts during the lifetime of nfs_page 
>>> structs which
>>> leads to a misscounted refcount...but as I said I never looked back 
>>> into that
>>> again (but never say never...)
>>>
>>> Hope this helps...
>>
>> Hmm, interesting..
>>
>> Will you share your reproducer with me?  That will save me some time.
> 
> Sure.
> 
> My reproducer is the attached nfs_stress.sh script; when invoked with the
> following params:
> 
> ./nfs_stress.sh -w 10 -s 160000 -t 10
> 
> it leads to a crash within 10secs BUT ONLY with 64KB page Kconfig AND ONLY if
> the above wsize workaround is NOT applied. (or the cleanup-code trick mentioned
> in the emails) (the choice of the -s size parameter seemed sensible in determine
> how quick it will die...)
> 
> BUT UNFORTUNATELY this was true ONLY when running on an AEMv8 FastModel (1-cpu
> A53) (whose timings are much different from a real board); I've never been able
> to reproduce reliably on real ARM64 silicon instead. (or on x86)
> So all my debug and triage was made on the model once I was able to quickly
> reproduce the same crash (and in fact the workaround worked then fine also on
> silicon...)
> 
> On real silicon instead the only reproducer was a full LTP run: we had
> consistent failures every night with the same exact refcount stacktrace (but
> every time on a different LTP test as a trigger...being related to NFS activity
> I suppose it's normal); since we applied the wsize workaround we saw no more
> crashes.
> 

I'll try to have a look at my old notes, but afaicr my suspicion that time was
on some NFS code-path in the early life of the nfs_page where a refcount +1 is
set conditional to some other nfs_page flags, so that a race could have happened
between the flags check and the +1 itself (and this could have been influenced
by the fact that a 64kb page took longer to be written out in 4kb wsize chunks...).
One thing which I remember while ftracing is that this thing happened after
after 10secs on a flock of pages...was not only one..you ended up with 3-5 or
more nfs_pages linked between themselves all with a dirty wrong refcount...and
those nfs_pages addresses where perfectly fine till a while before (so the same
nfs_page which I could see going through a clean free with proper refcount, when
re-used later in the test ended up being freed ahead of time due to a miscounted
refcount).

Regards

Cristian
> 
> Thanks
> 
> Regards
> 
> Cristian
> 
>>
>> Ben
>>
> 

