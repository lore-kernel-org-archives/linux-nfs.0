Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:43054 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab1I0Qtk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 12:49:40 -0400
Date: Tue, 27 Sep 2011 09:49:37 -0700
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS client growing system CPU
Message-ID: <20110927164937.GA2690@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org> <20110927003931.GB12106@hostway.ca> <1317123773.24383.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317123773.24383.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 07:42:53AM -0400, Trond Myklebust wrote:

> On Mon, 2011-09-26 at 17:39 -0700, Simon Kirby wrote: 
> > Hello!
> > 
> > Following up on "System CPU increasing on idle 2.6.36", this issue is
> > still happening even on 3.1-rc7. So, since it has been 9 months since I
> > reported this, I figured I'd bisect this issue. The first bisection ended
> > in an IPMI regression that looked like the problem, so I had to start
> > again. Eventually, I got commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
> > which made it into 2.6.34-rc4.
> > 
> > With this commit, system CPU keeps rising as the log crunch box runs
> > (reads log files via NFS and spews out HTML files into NFS-mounted report
> > directories). When it finishes the daily run, the system time stays
> > non-zero and continues to be higher and higher after each run, until the
> > box never completes a run within a day due to all of the wasted cycles.
> 
> So reverting that commit fixes the problem on 3.1-rc7?
> 
> As far as I can see, doing so should be safe thanks to commit
> 5547e8aac6f71505d621a612de2fca0dd988b439 (writeback: Update dirty flags
> in two steps) which fixes the original problem at the VFS level.

Hmm, I went to git revert b80c3cb628f0ebc241b02e38dd028969fb8026a2, but
for some reason git left the nfs_mark_request_dirty(req); line in
nfs_writepage_setup(), even though the original commit had that. Is that
OK or should I remove that as well?

Once that is sorted, I'll build it and let it run for a day and let you
know. Thanks!

Simon-
