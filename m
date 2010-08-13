Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:40741 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab0HMT5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 15:57:16 -0400
Date: Fri, 13 Aug 2010 15:57:14 -0400
From: Jim Rees <rees@umich.edu>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: john stultz <johnstul@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100813195714.GB12061@merit.edu>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
 <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Patrick J. LoPresti wrote:

  On Fri, Aug 13, 2010 at 11:45 AM, john stultz <johnstul@us.ibm.com> wrote:

  > On those TSC broken systems that use the hpet or acpi_pm, a
  > getnstimeofday call can take 0.5-1.3us, so the penalty can be quite
  > severe.
  
  So you are saying my proposal is a bad idea forever?  (But then why
  even bother having nanosecond resolution on ext4?)

How about using getnstimeofday() only if the kernel clocksource is tsc?
Presumably anyone running into this problem would have modern high
performance hardware with working tsc.
