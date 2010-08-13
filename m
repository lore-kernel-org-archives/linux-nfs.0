Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:57662 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754565Ab0HMTJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 15:09:46 -0400
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: john stultz <johnstul@us.ibm.com>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	 <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
	 <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 Aug 2010 12:09:39 -0700
Message-ID: <1281726579.2810.10.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-08-13 at 11:57 -0700, Patrick J. LoPresti wrote:
> On Fri, Aug 13, 2010 at 11:45 AM, john stultz <johnstul@us.ibm.com> wrote:
> > On those TSC broken systems that use the hpet or acpi_pm, a
> > getnstimeofday call can take 0.5-1.3us, so the penalty can be quite
> > severe.
> 
> So you are saying my proposal is a bad idea forever?  (But then why
> even bother having nanosecond resolution on ext4?)
> 
> Or that it is a bad idea for now?

I'm not judging the idea as good/bad, just providing information for
context.

> Or that it needs to be refined?  Maybe use hi-res precision on systems
> where it is known to be fast?
> 
> > And even with the TSC, expect some performance impact, as
> > reading hardware and doing the multiply is more costly then just
> > fetching a value from memory.
> 
> Relative to file system operations?  Seriously?  What performance hit
> would you expect on real-world applications?
> Something like 0.1% (10 nsec / 10 usec) worst case?

If you can show this does not affect performance in benchmarks, etc, I'm
sure it will be easier to push the patch. As outside of performance, I
don't think there's much of an issue with the change.

So other then "show some numbers", my only thought that might make the
patch more attractive is that rather than a global change, or a static
CONFIG_ option, would it maybe make more sense as a mount option?

thanks
-john

