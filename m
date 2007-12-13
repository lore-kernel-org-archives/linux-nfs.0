From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NLM: Add lockd reference counting and clean up lockd
	startup and shutdown
Date: Thu, 13 Dec 2007 10:24:49 -0500
Message-ID: <1197559489.11586.1.camel@heimdal.trondhjem.org>
References: <1197118932-4512-1-git-send-email-jlayton@redhat.com>
	<20071208140747.GA11675@infradead.org>
	<20071213094009.7a7e1923@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071213094009.7a7e1923@tleilax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-13 at 09:40 -0500, Jeff Layton wrote:
> On Sat, 8 Dec 2007 14:07:47 +0000
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > > +	mutex_lock(&nlmsvc_mutex);
> > > +	while (atomic_read(&nlmsvc_ref) != 0) {
> > 
> > might be better to do the refcounting outside the thread and use the
> > kthread api, which is something we still need to do for lockd anyway.
> > 
> 
> I took a swipe at doing this, and have a set of patches that make lockd
> use kthreads. It works well, but there's a problem once I add in the
> reference counting.
> 
> In the situation that prompted this whole thing, the last nlmsvc_ref
> gets put by lockd itself. A kthread can't call kthread_stop on itself
> since it will deadlock.
> 
> Is there a way to gracefully allow a kthread to shut itself down?
> Alternately, I suppose I could schedule_work() the kthread_stop, though
> that seems sort of ugly...

How about just 'return'? :-)

You shouldn't need to signal yourself to stop.

Cheers
  Trond
