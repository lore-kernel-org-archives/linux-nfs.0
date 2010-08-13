Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60807 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751342Ab0HMUwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 16:52:53 -0400
Date: Fri, 13 Aug 2010 16:52:49 -0400
From: Jim Rees <rees@umich.edu>
To: john stultz <johnstul@us.ibm.com>
Cc: "Patrick J. LoPresti" <lopresti@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100813205249.GA12404@merit.edu>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
 <AANLkTin2P5kcrC1SU-ANffSHyW8Ar4x4+qFuqVMFhYJE@mail.gmail.com>
 <AANLkTin-dksybH0ANypheovXXubwd+SRCpurdVRU7-Z=@mail.gmail.com>
 <20100813195714.GB12061@merit.edu>
 <1281731186.2810.17.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1281731186.2810.17.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

john stultz wrote:

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

It just would be nice if the kernel could "do the right thing" without the
user having to set some option or sysctl.  The problem is infrequently seen,
difficult to diagnose, and not obvious as to whether it's a client or server
issue.  I don't think your typical user, or even your typical professional
sysadmin, is going to get this right if it requires a setting.

Having said that, it's not obvious to me how to do this automatically.
