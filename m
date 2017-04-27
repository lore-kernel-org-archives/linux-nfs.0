Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1423217AbdD0WDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Apr 2017 18:03:44 -0400
Date: Thu, 27 Apr 2017 18:03:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Fix callback server shutdown
Message-ID: <20170427220342.GC29775@parsley.fieldses.org>
References: <20170426155527.92213-1-trond.myklebust@primarydata.com>
 <20170426155527.92213-2-trond.myklebust@primarydata.com>
 <20170426155527.92213-3-trond.myklebust@primarydata.com>
 <1692a8de-1d22-dfdd-d36f-e2b040160e26@gmail.com>
 <1493263484.1401.2.camel@primarydata.com>
 <4275e06f-97c0-b5b9-e71c-db7380d90534@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4275e06f-97c0-b5b9-e71c-db7380d90534@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 27, 2017 at 11:54:48AM +0800, Kinglong Mee wrote:
> 
> 
> On 4/27/2017 11:24, Trond Myklebust wrote:
> > On Thu, 2017-04-27 at 11:06 +0800, Kinglong Mee wrote:
> >>
> >> There is only one use of svc_set_num_threads that by nfsd,
> >> I'd like to change svc_set_num_threads and update nfsd than add a new
> >> function.
> > 
> > You can't really combine the two methods. Either you choose signals or
> > you choose kthread_stop(). The problem is that signals require the
> > thread to be able to persist past the nfsd_destroy() (which again
> > forces things like nfsd() having to take nfsd_mutex), or you have to
> > make things synchronous, in which case having nfsd() try to take
> > nfsd_mutex causes deadlocks.
> > 
> > IOW: if there is legacy behaviour here that requires the signal method,
> > then knfsd cannot be converted.
> 
> Got it.
> 
> Tested-and-reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

So does what I have in git://linux-nfs.org/~bfields/linux.git nfsd-next
look correct?

(Alternatively, if Trond's taking this through his tree, that's fine
too, feel free to add my ACK.)

--b.
