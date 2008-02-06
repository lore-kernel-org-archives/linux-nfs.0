From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Wed, 6 Feb 2008 14:09:35 -0500
Message-ID: <20080206140935.3d531bbf@barsoom.rdu.redhat.com>
References: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
	<1202322103-13716-2-git-send-email-jlayton@redhat.com>
	<1202322103-13716-3-git-send-email-jlayton@redhat.com>
	<1202322991.8549.7.camel@heimdal.trondhjem.org>
	<20080206134702.14c9d4f0@barsoom.rdu.redhat.com>
	<1202323955.8549.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbYBFTJ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 14:09:59 -0500
In-Reply-To: <1202323955.8549.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 06 Feb 2008 13:52:34 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Wed, 2008-02-06 at 13:47 -0500, Jeff Layton wrote:
> > There's no guarantee that kthread_stop() won't wake up lockd before
> > schedule_timeout() gets called, but after the last check for
> > kthread_should_stop().
> 
> Doesn't the BKL pretty much eliminate this race? (assuming you
> transform that call to 'if (!kthread_should_stop())
> schedule_timeout();')
> 
> Trond
> 

I don't think so. That would require that lockd_down is always called
with the BKL held, and I don't think it is, is it?
-- 
Jeff Layton <jlayton@redhat.com>
