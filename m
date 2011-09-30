Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34694 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932112Ab1I3BLf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 21:11:35 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS client growing system CPU
Date: Thu, 29 Sep 2011 18:11:17 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B6C979E@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110930005807.GE7959@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org> <20110927003931.GB12106@hostway.ca> <1317123773.24383.1.camel@lade.trondhjem.org> <20110927164937.GA2690@hostway.ca> <1317143055.10143.2.camel@lade.trondhjem.org> <20110928195835.GA15368@hostway.ca> <20110930005807.GE7959@hostway.ca>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Simon Kirby" <sim@hostway.ca>
Cc: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Simon Kirby [mailto:sim@hostway.ca]
> Sent: Thursday, September 29, 2011 8:58 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: NFS client growing system CPU
> 
> On Wed, Sep 28, 2011 at 12:58:35PM -0700, Simon Kirby wrote:
> 
> > On Tue, Sep 27, 2011 at 01:04:15PM -0400, Trond Myklebust wrote:
> >
> > > On Tue, 2011-09-27 at 09:49 -0700, Simon Kirby wrote:
> > > > On Tue, Sep 27, 2011 at 07:42:53AM -0400, Trond Myklebust wrote:
> > > >
> > > > > On Mon, 2011-09-26 at 17:39 -0700, Simon Kirby wrote:
> > > > > > Hello!
> > > > > >
> > > > > > Following up on "System CPU increasing on idle 2.6.36", this
> > > > > > issue is still happening even on 3.1-rc7. So, since it has
> > > > > > been 9 months since I reported this, I figured I'd bisect
this
> > > > > > issue. The first bisection ended in an IPMI regression that
> > > > > > looked like the problem, so I had to start again.
Eventually,
> > > > > > I got commit b80c3cb628f0ebc241b02e38dd028969fb8026a2
> > > > > > which made it into 2.6.34-rc4.
> > > > > >
> > > > > > With this commit, system CPU keeps rising as the log crunch
> > > > > > box runs (reads log files via NFS and spews out HTML files
> > > > > > into NFS-mounted report directories). When it finishes the
> > > > > > daily run, the system time stays non-zero and continues to
be
> > > > > > higher and higher after each run, until the box never
completes a
> run within a day due to all of the wasted cycles.
> > > > >
> > > > > So reverting that commit fixes the problem on 3.1-rc7?
> > > > >
> > > > > As far as I can see, doing so should be safe thanks to commit
> > > > > 5547e8aac6f71505d621a612de2fca0dd988b439 (writeback: Update
> > > > > dirty flags in two steps) which fixes the original problem at
the VFS
> level.
> > > >
> > > > Hmm, I went to git revert
> > > > b80c3cb628f0ebc241b02e38dd028969fb8026a2, but for some reason
git
> > > > left the nfs_mark_request_dirty(req); line in
> > > > nfs_writepage_setup(), even though the original commit had that.
Is
> that OK or should I remove that as well?
> > > >
> > > > Once that is sorted, I'll build it and let it run for a day and
> > > > let you know. Thanks!
> > >
> > > It shouldn't make any difference whether you leave it or remove
it.
> > > The resulting second call to __set_page_dirty_nobuffers() will
> > > always be a no-op since the page will already be marked as dirty.
> >
> > Ok, confirmed, git revert b80c3cb628f0ebc241b02e38dd028969fb8026a2
on
> > 3.1-rc7 fixes the problem for me. Does this make sense, then, or do
we
> > need further investigation and/or testing?
> 
> Just to clear up what I said before, it seems that on plain 3.1-rc8, I
am actually
> able to clear the endless CPU use in nfs_writepages by just running
"sync". I
> am not sure when this changed, but I'm pretty sure that some versions
> between 2.6.34 and 3.1-rc used to not be affected by just "sync"
unless it
> was paired with drop_caches. Maybe this makes the problem more
> obvious...

Hi Simon,

I think you are just finding yourself cycling through the VFS writeback
routines all the time because we dirty the inode for COMMIT at the same
time as we dirty a new page. Usually, we want to wait until after the
WRITE rpc call has completed, and so it was only the vfs race that
forced us to write this workaround so that we can guarantee reliable
fsync() behaviour.

My only concern at this point is to make sure that in reverting that
patch, we haven't overlooked some other fsync() bug that this patch
fixed. So far, it looks as if Dmitry's patch is sufficient to deal with
any issues that I can see.

Cheers
  Trond
