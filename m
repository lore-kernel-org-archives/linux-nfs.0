Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:48797 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755213Ab0HMU0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 16:26:31 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7DKCS0t026897
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 16:12:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7DKQUAD2289668
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 16:26:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7DKQUcI020399
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 17:26:30 -0300
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: john stultz <johnstul@us.ibm.com>
To: Jim Rees <rees@umich.edu>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20100813195714.GB12061@merit.edu>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	 <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
	 <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
	 <20100813195714.GB12061@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 Aug 2010 13:26:26 -0700
Message-ID: <1281731186.2810.17.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-08-13 at 15:57 -0400, Jim Rees wrote:
> Patrick J. LoPresti wrote:
> 
>   On Fri, Aug 13, 2010 at 11:45 AM, john stultz <johnstul@us.ibm.com> wrote:
> 
>   > On those TSC broken systems that use the hpet or acpi_pm, a
>   > getnstimeofday call can take 0.5-1.3us, so the penalty can be quite
>   > severe.
>   
>   So you are saying my proposal is a bad idea forever?  (But then why
>   even bother having nanosecond resolution on ext4?)
> 
> How about using getnstimeofday() only if the kernel clocksource is tsc?
> Presumably anyone running into this problem would have modern high
> performance hardware with working tsc.

This might be difficult, as clocksources can change while the system is
running. Further, any checks for specific clocksources would be very
architecture specific. A fast-timekeeping flag could be used, but would
be a fairly subjective metric (ie: would there be issues if the fast
clock on a  slower system is slower then a slow clock on a fast system,
etc).

That's partly why I suggested a mount option.

thanks
-john



