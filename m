From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error
Date: Fri, 18 Dec 2009 09:39:12 -0500
Message-ID: <20091218093912.1c426ad6@tlielax.poochiereds.net>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1261145468.3229.7.camel@localhost>
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

On Fri, 18 Dec 2009 09:11:08 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2009-12-18 at 08:56 -0500, Jeff Layton wrote: 
> > When handling the gssd downcall, the kernel should distinguish between a
> > successful downcall that contains an error code and a failed downcall
> > (i.e. where the parsing failed or some other sort of problem occurred).
> > 
> > In the former case, gss_pipe_downcall should be returning the number of
> > bytes written to the pipe instead of an error.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c |   21 +++++++++++++++++----
> >  1 files changed, 17 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 3c3c50f..03cc5a4 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -184,7 +184,8 @@ gss_alloc_context(void)
> >  
> >  #define GSSD_MIN_TIMEOUT (60 * 60)
> >  static const void *
> > -gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct gss_api_mech *gm)
> > +gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx,
> > +		 struct gss_api_mech *gm, ssize_t *downcall_err)
> >  {
> >  	const void *q;
> >  	unsigned int seclen;
> > @@ -208,6 +209,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
> >  	if (ctx->gc_win == 0) {
> >  		/* in which case, p points to  an error code which we ignore */
> >  		p = ERR_PTR(-EACCES);
> > +		*downcall_err = -EACCES;
> >  		goto err;
> >  	}
> >  	/* copy the opaque wire context */
> > @@ -641,10 +643,21 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> >  	list_del_init(&gss_msg->list);
> >  	spin_unlock(&inode->i_lock);
> >  
> > -	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech);
> > +	err = 0;
> > +	p = gss_fill_context(p, end, ctx, gss_msg->auth->mech, &err);
> >  	if (IS_ERR(p)) {
> > -		err = PTR_ERR(p);
> > -		gss_msg->msg.errno = (err == -EAGAIN) ? -EAGAIN : -EACCES;
> > +		/*
> > +		 * a non-zero downcall_err indicates that downcall write was
> > +		 * OK, but contained a zero gc_win (and hence an error code).
> > +		 */
> > +		if (err) {
> > +			gss_msg->msg.errno = err;
> > +			err = mlen;
> > +		} else {
> > +			err = PTR_ERR(p);
> > +			gss_msg->msg.errno = (err == -EAGAIN) ?
> > +							-EAGAIN : -EACCES;
> > +		}
> >  		goto err_release_msg;
> >  	}
> >  	gss_msg->ctx = gss_get_ctx(ctx);
> 
> Is this extra parameter really necessary? Can't we just distinguish
> between EACCES, which means that the downcall was successful, but
> contained an error, and EFAULT/ENOMEM/ENOSYS, which are context creation
> errors.
> 

Yeah, we could do that with the existing code. I sort of don't like
that because it's hard to know if other functions could eventually
return an EACCES for another reason and then that error would bubble up
to this function. If you think it's the right thing to do though, I'm
OK with it.

FWIW: The reason I'm poking around in here is because I'm taking a stab
at fixing the problem where syscalls start returning errors when a krb5
ticket expires.

As part of that, I want to have gssd send a more granular error code
and have the kernel adjust what it does accordingly. I'd like to have
it retry the upcall indefinitely when there's an expired credcache, and
return an error when there's no credcache at all).

Without a separate downcall error field, we'll need to special case at
least 2 different errors -- one for a "real" EACCES and one that
indicates that the ticket expired and the upcall should be retried
instead.

> BTW: while looking at this, I spotted a nasty bug in
> gss_import_sec_context_kerberos(). If the kzalloc() call fails, we will
> return a random error code since 'p' still points to a valid memory
> location...

Good catch. Do you want fix that one, or should I?

-- 
Jeff Layton <jlayton@redhat.com>
