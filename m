Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47546 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757419AbdECUVu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 16:21:50 -0400
Date: Wed, 3 May 2017 16:21:50 -0400
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Fix callback server shutdown
Message-ID: <20170503202150.GB21467@fieldses.org>
References: <20170426155527.92213-1-trond.myklebust@primarydata.com>
 <20170426155527.92213-2-trond.myklebust@primarydata.com>
 <20170426155527.92213-3-trond.myklebust@primarydata.com>
 <1692a8de-1d22-dfdd-d36f-e2b040160e26@gmail.com>
 <1493263484.1401.2.camel@primarydata.com>
 <4275e06f-97c0-b5b9-e71c-db7380d90534@gmail.com>
 <20170427220342.GC29775@parsley.fieldses.org>
 <1493330824.34802.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1493330824.34802.1.camel@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 27, 2017 at 10:07:07PM +0000, Trond Myklebust wrote:
> On Thu, 2017-04-27 at 18:03 -0400, J. Bruce Fields wrote:
> > On Thu, Apr 27, 2017 at 11:54:48AM +0800, Kinglong Mee wrote:
> > > 
> > > 
> > > On 4/27/2017 11:24, Trond Myklebust wrote:
> > > > On Thu, 2017-04-27 at 11:06 +0800, Kinglong Mee wrote:
> > > > > 
> > > > > There is only one use of svc_set_num_threads that by nfsd,
> > > > > I'd like to change svc_set_num_threads and update nfsd than add
> > > > > a new
> > > > > function.
> > > > 
> > > > You can't really combine the two methods. Either you choose
> > > > signals or
> > > > you choose kthread_stop(). The problem is that signals require
> > > > the
> > > > thread to be able to persist past the nfsd_destroy() (which again
> > > > forces things like nfsd() having to take nfsd_mutex), or you have
> > > > to
> > > > make things synchronous, in which case having nfsd() try to take
> > > > nfsd_mutex causes deadlocks.
> > > > 
> > > > IOW: if there is legacy behaviour here that requires the signal
> > > > method,
> > > > then knfsd cannot be converted.
> > > 
> > > Got it.
> > > 
> > > Tested-and-reviewed-by: Kinglong Mee <kinglongmee@gmail.com>
> > 
> > So does what I have in git://linux-nfs.org/~bfields/linux.git nfsd-
> > next
> > look correct?
> > 
> > (Alternatively, if Trond's taking this through his tree, that's fine
> > too, feel free to add my ACK.)
> > 
> If you've already got it queued up then I'm fine with that. I have it
> in my "testing" branch (which passes ☺) but haven't yet moved it into
> linux-next.

OK, I'll take it.

--b.
