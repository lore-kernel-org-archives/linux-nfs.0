From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: don't let lockd exit on unexpected svc_recv errors
	(try #2)
Date: Tue, 8 Apr 2008 16:23:51 -0400
Message-ID: <20080408162351.3fd33ed7@tleilax.poochiereds.net>
References: <1207683608-17550-1-git-send-email-jlayton@redhat.com>
	<1207683608-17550-2-git-send-email-jlayton@redhat.com>
	<1207685758.11699.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207685758.11699.28.camel@heimdal.trondhjem.org>
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

On Tue, 08 Apr 2008 16:15:58 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Tue, 2008-04-08 at 15:40 -0400, Jeff Layton wrote:
> > When svc_recv returns an unexpected error, lockd will print a warning
> > and exit. This problematic for several reasons. In particular, it will
> > cause the reference counts for the thread to be wrong, and can lead to a
> > potential BUG() call.
> > 
> > Rather than exiting on error from svc_recv, have the thread do a 1s
> > sleep and then retry the loop. This is unlikely to cause any harm, and
> > if the error turns out to be something temporary then it may be able to
> > recover.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/lockd/svc.c |   18 ++++++++++++------
> >  1 files changed, 12 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index 66b5c98..cf977bb 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> > @@ -112,7 +112,7 @@ static inline void clear_grace_period(void)
> >  static int
> >  lockd(void *vrqstp)
> >  {
> > -	int		err = 0;
> > +	int		err = 0, preverr = 0;
> >  	struct svc_rqst *rqstp = vrqstp;
> >  	unsigned long grace_period_expire;
> >  
> > @@ -172,14 +172,20 @@ lockd(void *vrqstp)
> >  		 * recvfrom routine.
> >  		 */
> >  		err = svc_recv(rqstp, timeout);
> > -		if (err == -EAGAIN || err == -EINTR)
> > +		if (err == -EAGAIN || err == -EINTR) {
> > +			preverr = err;
> >  			continue;
> > +		}
> >  		if (err < 0) {
> > -			printk(KERN_WARNING
> > -			       "lockd: terminating on error %d\n",
> > -			       -err);
> > -			break;
> > +			if (err != preverr) {
> > +				printk(KERN_WARNING "%s: unexpected error "
> > +					"from svc_recv (%d)\n", __func__, err);
> > +				preverr = err;
> > +			}
> > +			schedule_timeout_interruptible(HZ);
> 
> Why not use an uninterruptible sleep?
> 
> Trond
> 

lockd can receive a SIGKILL to tell it to drop all locks, so I figured
it was reasonable to allow the sleep to be interrupted if that happens.
It probably doesn't matter much either way though...

-- 
Jeff Layton <jlayton@redhat.com>
