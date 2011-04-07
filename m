Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65409.mail.ac4.yahoo.com ([76.13.9.29]:37946 "HELO
	web65409.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751994Ab1DGVtt convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 17:49:49 -0400
Message-ID: <770047.76192.qm@web65409.mail.ac4.yahoo.com>
Date: Thu, 7 Apr 2011 14:49:47 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Jim Rees <rees@umich.edu>,
        Garth Gibson <garth@cs.cmu.edu>, linux-nfs@vger.kernel.org
In-Reply-To: <514401.95922.qm@web65408.mail.ac4.yahoo.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Thu, 4/7/11, Andrew Klaassen <clawsoon@yahoo.com> wrote:

> I do notice that ksoftirqd is eating up 100% of a core when
> I'm loading the server heavily.  I assume that's
> because I'm not using jumbo frames and the ethernet cards
> are spitting out interrupts as fast as they're able.

I just got myself edjumicated on smp_affinity, and now I'm able to achieve 99% CPU usage by 8 nfsd processes on 8 cores on a read-only, fully-cached workload, with ksoftirqd processes only using 1% CPU per core.

Unfortunately, this doesn't help the "ls -l" speed.

Andrew


