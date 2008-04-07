From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Mon, 7 Apr 2008 13:40:41 -0400
Message-ID: <20080407134041.34f93fbd@tleilax.poochiereds.net>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
	<1207575514-6703-2-git-send-email-jlayton@redhat.com>
	<20080407164500.GA17728@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080407164500.GA17728@infradead.org>
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

On Mon, 7 Apr 2008 12:45:01 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> > The global task and serv pointers for lockd are normally protected by
> > the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> > this occurs, these variables are cleared without any locking.
> 
> Shouldn't we get rid of the case where it exits abnormally instead?
> 

Not a bad idea. After chatting with Christoph a bit on IRC, I suppose
we have 2 options if we want to pursue this. When we get an unexpected
error from svc_recv(), we could:

1) sleep for a bit and then retry

2) call schedule() and sleep until kthread_stop shuts down the thread

I think #1 is probably the best option. It's certainly the more fault
tolerant. That also fixes another potential problem -- right now if the
thread exits and the nlmsvc_users count isn't 0, then we can
potentially BUG() on the next lockd_up/lockd_down.

Any thoughts on what an appropriate sleep timeout should be when this
happens? I was thinking 1s or so...

Trond, Bruce, any thoughts?

-- 
Jeff Layton <jlayton@redhat.com>
