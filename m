Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65408.mail.ac4.yahoo.com ([76.13.9.28]:26901 "HELO
	web65408.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751527Ab1DGVZQ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 17:25:16 -0400
Message-ID: <514401.95922.qm@web65408.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 14:25:10 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <CCB59DB2-C865-4C36-BB77-1A76E6B261E9@oracle.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Thu, 4/7/11, Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 7, 2011, at 10:34 AM, Andrew Klaassen wrote:
> 
> > --- On Thu, 4/7/11, Chuck Lever <chuck.lever@oracle.com>
> wrote:
> >> Have you created enough nfsd threads on your Linux NFS
> >> servers?
> > 
> > That was one of the things I varied as part of my
> > testing; almost every power of 2 from 8 threads up to 1024
> > threads.  It actually made things slightly worse, not
> > better, but I can certainly give it a try again.
> 
> Is the server an SMP system?

Yes.

> Do you see high CPU load during times of slow performance?

I've found two cases when throughput is high and "ls -l" is slow:

 - disk-bound, when I'm (purposely) pumping through more data than can be held in the cache.  In this case, CPU idle time generally remains between 30-60%.

 - fully-cached read-only, when... well, it looks like I'll have to get back to you on this one, since ext4lazyinit has to finish its thing before I can reproduce this case.

I do notice that ksoftirqd is eating up 100% of a core when I'm loading the server heavily.  I assume that's because I'm not using jumbo frames and the ethernet cards are spitting out interrupts as fast as they're able.

Unfortunately, upgrading the hardware - either disks or CPU - is not an option.  This is why I was hoping there was some way to send readdirplus/getattr/lookup calls to the front of the queue on the server side even when the hardware has reached its limits.

Andrew


