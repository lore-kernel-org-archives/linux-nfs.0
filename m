Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:44090 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935438Ab1JEXHq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Oct 2011 19:07:46 -0400
Date: Wed, 5 Oct 2011 16:07:43 -0700
From: Simon Kirby <sim@hostway.ca>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Mark Moseley <moseleymark@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS client growing system CPU
Message-ID: <20111005230743.GB31168@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org> <20110927003931.GB12106@hostway.ca> <1317123773.24383.1.camel@lade.trondhjem.org> <20110927164937.GA2690@hostway.ca> <1317143055.10143.2.camel@lade.trondhjem.org> <20110928195835.GA15368@hostway.ca> <20110930005807.GE7959@hostway.ca> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B6C979E@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B6C979E@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 29, 2011 at 06:11:17PM -0700, Myklebust, Trond wrote:

> > -----Original Message-----
> > From: Simon Kirby [mailto:sim@hostway.ca]
> > Sent: Thursday, September 29, 2011 8:58 PM
> > To: Myklebust, Trond
> > Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> > Subject: Re: NFS client growing system CPU
> > 
> > On Wed, Sep 28, 2011 at 12:58:35PM -0700, Simon Kirby wrote:
> > 
> > > On Tue, Sep 27, 2011 at 01:04:15PM -0400, Trond Myklebust wrote:
> > >
> > > > On Tue, 2011-09-27 at 09:49 -0700, Simon Kirby wrote:
> > > > > On Tue, Sep 27, 2011 at 07:42:53AM -0400, Trond Myklebust wrote:
> > > > >
> > > > > > On Mon, 2011-09-26 at 17:39 -0700, Simon Kirby wrote:
> > > > > > > Hello!
> > > > > > >
> > > > > > > Following up on "System CPU increasing on idle 2.6.36", this
> > > > > > > issue is still happening even on 3.1-rc7. So, since it has
> > > > > > > been 9 months since I reported this, I figured I'd bisect
> this
> > > > > > > issue. The first bisection ended in an IPMI regression that
> > > > > > > looked like the problem, so I had to start again.
> Eventually,
> > > > > > > I got commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
> > > > > > > which made it into 2.6.34-rc4.
> > > > > > >
> > > > > > > With this commit, system CPU keeps rising as the log crunch
> > > > > > > box runs (reads log files via NFS and spews out HTML files
> > > > > > > into NFS-mounted report directories). When it finishes the
> > > > > > > daily run, the system time stays non-zero and continues to
> be
> > > > > > > higher and higher after each run, until the box never
> completes a
> > run within a day due to all of the wasted cycles.
> > > > > >
> > > > > > So reverting that commit fixes the problem on 3.1-rc7?
> > > > > >
> > > > > > As far as I can see, doing so should be safe thanks to commit
> > > > > > 5547e8aac6f71505d621a612de2fca0dd988b439 (writeback: Update
> > > > > > dirty flags in two steps) which fixes the original problem at
> the VFS
> > level.
> > > > >
> > > > > Hmm, I went to git revert
> > > > > b80c3cb628f0ebc241b02e38dd028969fb8026a2, but for some reason
> git
> > > > > left the nfs_mark_request_dirty(req); line in
> > > > > nfs_writepage_setup(), even though the original commit had that.
> Is
> > that OK or should I remove that as well?
> > > > >
> > > > > Once that is sorted, I'll build it and let it run for a day and
> > > > > let you know. Thanks!
> > > >
> > > > It shouldn't make any difference whether you leave it or remove
> it.
> > > > The resulting second call to __set_page_dirty_nobuffers() will
> > > > always be a no-op since the page will already be marked as dirty.
> > >
> > > Ok, confirmed, git revert b80c3cb628f0ebc241b02e38dd028969fb8026a2
> on
> > > 3.1-rc7 fixes the problem for me. Does this make sense, then, or do
> we
> > > need further investigation and/or testing?
> > 
> > Just to clear up what I said before, it seems that on plain 3.1-rc8, I
> am actually
> > able to clear the endless CPU use in nfs_writepages by just running
> "sync". I
> > am not sure when this changed, but I'm pretty sure that some versions
> > between 2.6.34 and 3.1-rc used to not be affected by just "sync"
> unless it
> > was paired with drop_caches. Maybe this makes the problem more
> > obvious...
> 
> Hi Simon,
> 
> I think you are just finding yourself cycling through the VFS writeback
> routines all the time because we dirty the inode for COMMIT at the same
> time as we dirty a new page. Usually, we want to wait until after the
> WRITE rpc call has completed, and so it was only the vfs race that
> forced us to write this workaround so that we can guarantee reliable
> fsync() behaviour.
> 
> My only concern at this point is to make sure that in reverting that
> patch, we haven't overlooked some other fsync() bug that this patch
> fixed. So far, it looks as if Dmitry's patch is sufficient to deal with
> any issues that I can see.

Hello!

So, this is a regression that has caused uptime issues for us since
2.6.34-rc4. Dmitry's patch went into 2.6.35, so I think this revert
should be committed and be a stable candidate for 2.6.35 - 3.1.

We have not seen any problems resulting from the revert, but our loads
are not particularly fsync()-heavy. How did things work before this
patch, anyway?

Here is another graph showing the revert fixing the problem on this box
with relatively simple workload (revert applied Tuesday evening):

http://0x.ca/sim/ref/3.1-rc8/cpu-analog02-revert-b80c3cb6.png

It is helping on many other boxes, too, but they get various spurts of
memory pressure and other CPU spikes that cause the difference to be
harder to see. We're still running your sunrpc/clnt.c debugging patch as
well, but haven't hit the hang again yet.

Simon-
