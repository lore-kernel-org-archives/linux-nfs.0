Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:51131 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab0HMSp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:45:56 -0400
In-Reply-To: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
Date: Fri, 13 Aug 2010 11:45:54 -0700
Message-ID: <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: john stultz <johnstul@us.ibm.com>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 11:25 AM, Patrick J. LoPresti
<lopresti@gmail.com> wrote:
> 3) On the 99.99% of Linux systems that are post-1990 x86, it is not
> slow at all, and the performance difference will be utterly
> undetectable in the real world.

Your stats are off here. The only fast clocksource on x86 is the TSC,
and its busted on many, many systems. The cpu vendors have only
recently taken it seriously and resolved the majority of problems
(however, issues still remain on large numa systems, but its much
better then the story was 3-7 years ago).

On those TSC broken systems that use the hpet or acpi_pm, a
getnstimeofday call can take 0.5-1.3us, so the penalty can be quite
severe. And even with the TSC, expect some performance impact, as
reading hardware and doing the multiply is more costly then just
fetching a value from memory.

thanks
-john
