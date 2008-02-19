From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: flush signals before taking down callback thread
Date: Tue, 19 Feb 2008 18:00:40 -0500
Message-ID: <20080219180040.7a40c991@tleilax.poochiereds.net>
References: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
	<20080219222226.GA10656@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080219222226.GA10656@infradead.org>
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

On Tue, 19 Feb 2008 17:22:26 -0500
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Feb 19, 2008 at 12:51:35PM -0500, Jeff Layton wrote:
> > Now that the reference counting on the callback thread is working as
> > expected, it uncovers another problem.  Peter Staubach noticed while
> > testing that patch on an older kernel that he would occasionally see
> > this printk in rpc_register fire:
> > 
> >     "RPC: failed to contact portmap (errno -512).
> > 
> > The NFSv4 callback thread is signaled by nfs_callback_down(), but never
> > flushes that signal. All of the shutdown processing is done with that
> > signal pending. This makes it fail the call to unregister the port with
> > the portmapper.
> > 
> > In actuality, this rpc_register call isn't necessary at all since the
> > port isn't actually registered with the portmapper anymore. Regardless,
> > there doesn't seem to be any reason to leave the signal pending while
> > the thread is being shut down and flushing it should generally silence
> > that printk.
> 
> Wouldn't it be better to not allow for signals to this thread at all?
> The code really begs for a similar kthread conversion as the lockd one.

Yep, and I have such a patch already. I just need to test it out a bit
more before I send it out. I mainly sent this out to get the existing
code into shape before we do the conversion. That way if we have to
revert that conversion later, we won't be reverting to something broken.

But if Trond would rather not worry about it we can probably skip this
patch and I'll just send out the kthread conversion once I have some
more time to test it out.

-- 
Jeff Layton <jlayton@redhat.com>
