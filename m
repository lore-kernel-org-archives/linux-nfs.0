Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64563 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136Ab1DHPRz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Apr 2011 11:17:55 -0400
Subject: Re: Prioritizing readdirplus/getattr/lookup
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <770047.76192.qm@web65409.mail.ac4.yahoo.com>
Date: Fri, 8 Apr 2011 11:17:43 -0400
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
Message-Id: <F8F557F7-8799-449A-94FD-12FF5FC2974C@oracle.com>
References: <770047.76192.qm@web65409.mail.ac4.yahoo.com>
To: Andrew Klaassen <clawsoon@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 7, 2011, at 5:49 PM, Andrew Klaassen wrote:

> --- On Thu, 4/7/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:
> 
>> I do notice that ksoftirqd is eating up 100% of a core when
>> I'm loading the server heavily.  I assume that's
>> because I'm not using jumbo frames and the ethernet cards
>> are spitting out interrupts as fast as they're able.
> 
> I just got myself edjumicated on smp_affinity, and now I'm able to achieve 99% CPU usage by 8 nfsd processes on 8 cores on a read-only, fully-cached workload, with ksoftirqd processes only using 1% CPU per core.
> 
> Unfortunately, this doesn't help the "ls -l" speed.

Serving NFS files is generally not CPU intensive.  The problem may be lock contention on the server, but that's about as far as my expertise goes.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




