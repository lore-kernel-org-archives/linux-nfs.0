Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446Ab1I0Lmz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 07:42:55 -0400
Subject: Re: NFS client growing system CPU
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 27 Sep 2011 07:42:53 -0400
In-Reply-To: <20110927003931.GB12106@hostway.ca>
References: <20101208212505.GA18192@hostway.ca>
	 <1291845189.3067.31.camel@heimdal.trondhjem.org>
	 <20110927003931.GB12106@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317123773.24383.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-26 at 17:39 -0700, Simon Kirby wrote: 
> Hello!
> 
> Following up on "System CPU increasing on idle 2.6.36", this issue is
> still happening even on 3.1-rc7. So, since it has been 9 months since I
> reported this, I figured I'd bisect this issue. The first bisection ended
> in an IPMI regression that looked like the problem, so I had to start
> again. Eventually, I got commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
> which made it into 2.6.34-rc4.
> 
> With this commit, system CPU keeps rising as the log crunch box runs
> (reads log files via NFS and spews out HTML files into NFS-mounted report
> directories). When it finishes the daily run, the system time stays
> non-zero and continues to be higher and higher after each run, until the
> box never completes a run within a day due to all of the wasted cycles.

So reverting that commit fixes the problem on 3.1-rc7?

As far as I can see, doing so should be safe thanks to commit
5547e8aac6f71505d621a612de2fca0dd988b439 (writeback: Update dirty flags
in two steps) which fixes the original problem at the VFS level.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

