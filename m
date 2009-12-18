From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error (try #2)
Date: Fri, 18 Dec 2009 15:24:26 -0500
Message-ID: <1261167866.3420.40.camel@localhost>
References: <1261153637-6209-1-git-send-email-jlayton@redhat.com>
	<1261163139.3420.17.camel@localhost>
	<20091218151345.5e86149d@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091218151345.5e86149d@tlielax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 15:13 -0500, Jeff Layton wrote: 
> On Fri, 18 Dec 2009 14:05:39 -0500
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Fri, 2009-12-18 at 11:27 -0500, Jeff Layton wrote: 
> > > When handling the gssd downcall, the kernel should distinguish between a
> > > successful downcall that contains an error code and a failed downcall
> > > (i.e. where the parsing failed or some other sort of problem occurred).
> > > 
> > > In the former case, gss_pipe_downcall should be returning the number of
> > > bytes written to the pipe instead of an error.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  net/sunrpc/auth_gss/auth_gss.c |    3 +++
> > >  1 files changed, 3 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > > index 3c3c50f..7afc8e2 100644
> > > --- a/net/sunrpc/auth_gss/auth_gss.c
> > > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > > @@ -645,6 +645,9 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> > >  	if (IS_ERR(p)) {
> > >  		err = PTR_ERR(p);
> > >  		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
> > > +		/* special case: downcall was successful, but held an error */
> > > +		if (err == -EACCES)
> > > +			err = mlen;
> > 
> > That line immediately above your fix still looks wrong. The point is
> > that AFAICS, err is never going to be set to EAGAIN. It can be EFAULT,
> > ENOSYS, or ENOMEM, but it will never be EAGAIN...
> > 
> > I think we should rather reverse that test. Really, what we want to do,
> > is to set msg.errno to -EAGAIN for -EFAULT and -ENOMEM (and probably for
> > ENOSYS too), and then set it to -EACCES _only_ in the case where the
> > user was not authorised.
> 
> What should we do if err is "none of the above"? Set msg.errno to
> -EACCES and return the error to the pipe writer?
> 

The question is will it ever be 'none of the above'? We clearly cannot
be returning arbitrary errors to gssd, so we need to define a set that
makes sense. The only other error I can see that we might to add to the
above list, would be EINVAL (to mean 'you just sent me some garbage
argument that I cannot decode').

Retrying the upcall would seem to be the correct thing to do in case of
EINVAL too...

Trond
