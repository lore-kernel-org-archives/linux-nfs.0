From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Thu, 7 Feb 2008 06:37:14 -0500
Message-ID: <20080207063714.6f8a30d4@tleilax.poochiereds.net>
References: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
	<1202322103-13716-2-git-send-email-jlayton@redhat.com>
	<1202322103-13716-3-git-send-email-jlayton@redhat.com>
	<1202322991.8549.7.camel@heimdal.trondhjem.org>
	<20080206134702.14c9d4f0@barsoom.rdu.redhat.com>
	<1202323955.8549.24.camel@heimdal.trondhjem.org>
	<20080206140935.3d531bbf@barsoom.rdu.redhat.com>
	<1202338876.8549.45.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024AbYBGLhj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 06:37:39 -0500
In-Reply-To: <1202338876.8549.45.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 06 Feb 2008 18:01:16 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Wed, 2008-02-06 at 14:09 -0500, Jeff Layton wrote:
> > On Wed, 06 Feb 2008 13:52:34 -0500
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > 
> > > On Wed, 2008-02-06 at 13:47 -0500, Jeff Layton wrote:
> > > > There's no guarantee that kthread_stop() won't wake up lockd before
> > > > schedule_timeout() gets called, but after the last check for
> > > > kthread_should_stop().
> > > 
> > > Doesn't the BKL pretty much eliminate this race? (assuming you
> > > transform that call to 'if (!kthread_should_stop())
> > > schedule_timeout();')
> > > 
> > > Trond
> > > 
> > 
> > I don't think so. That would require that lockd_down is always called
> > with the BKL held, and I don't think it is, is it?
> 
> Nothing stops you from grabbing the BKL inside lockd_down, though :-)
> 

True, but what's worse -- keeping signaling in the codepath or
increasing reliance on the BKL? :-)

I think in the near term, you're probably right that taking the BKL in
lockd_down is the best scheme to prevent these races. I think the best
long term solution though is to add a way for kthread_stop to signal
the task before calling wait_for_completion.

I'll keep plugging away on this for now. If I can get a patch
upstream to add a kthread_stop_sig() call then we might be able to
avoid relying on the BKL here...

-- 
Jeff Layton <jlayton@redhat.com>
