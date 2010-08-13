Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33605 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab0HMS5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:57:45 -0400
In-Reply-To: <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
Date: Fri, 13 Aug 2010 11:57:43 -0700
Message-ID: <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: john stultz <johnstul@us.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 11:45 AM, john stultz <johnstul@us.ibm.com> wrote:
>
> Your stats are off here. The only fast clocksource on x86 is the TSC,
> and its busted on many, many systems. The cpu vendors have only
> recently taken it seriously and resolved the majority of problems
> (however, issues still remain on large numa systems, but its much
> better then the story was 3-7 years ago).

Thank you for the correction.  Still, the number of systems where TSC
works is large, it is growing over time, and....  Really now,
milliseconds?  In 2010?  On some Apple iToy, perhaps...

> On those TSC broken systems that use the hpet or acpi_pm, a
> getnstimeofday call can take 0.5-1.3us, so the penalty can be quite
> severe.

So you are saying my proposal is a bad idea forever?  (But then why
even bother having nanosecond resolution on ext4?)

Or that it is a bad idea for now?

Or that it needs to be refined?  Maybe use hi-res precision on systems
where it is known to be fast?

> And even with the TSC, expect some performance impact, as
> reading hardware and doing the multiply is more costly then just
> fetching a value from memory.

Relative to file system operations?  Seriously?  What performance hit
would you expect on real-world applications?
Something like 0.1% (10 nsec / 10 usec) worst case?

 - Pat
