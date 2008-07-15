From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/4] lockd: eliminate duplicate nlmsvc_lookup_host call
	from nlmsvc_testlock
Date: Tue, 15 Jul 2008 15:41:16 -0400
Message-ID: <20080715194116.GI21590@fieldses.org>
References: <20080715184554.GD21590@fieldses.org> <1216147693-23881-1-git-send-email-bfields@citi.umich.edu> <1216147693-23881-2-git-send-email-bfields@citi.umich.edu> <20080715190902.GF21590@fieldses.org> <20080715153222.1a894180@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40775 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758379AbYGOTl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 15:41:29 -0400
In-Reply-To: <20080715153222.1a894180-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 03:32:22PM -0400, Jeff Layton wrote:
> On Tue, 15 Jul 2008 15:09:02 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Jul 15, 2008 at 02:48:11PM -0400, J. Bruce Fields wrote:
> > > From: Jeff Layton <jlayton@redhat.com>
> > > 
> > > nlmsvc_testlock calls nlmsvc_lookup_host to find a nlm_host struct. The
> > > callers of this functions, however, call nlmsvc_retrieve_args or
> > > nlm4svc_retrieve_args, which also return a nlm_host struct.
> > > 
> > > Change nlmsvc_testlock to take a host arg instead of calling
> > > nlmsvc_lookup_host itself and change the callers to pass a pointer to
> > > the nlm_host they've already found.
> > > 
> > > We take a reference to host in the place where nlmsvc_testlock()
> > > previous did a new lookup, so the reference counting is unchanged from
> > > before.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > > ---
> > >  fs/lockd/svc4proc.c         |    2 +-
> > >  fs/lockd/svclock.c          |   12 +++---------
> > >  fs/lockd/svcproc.c          |    2 +-
> > >  include/linux/lockd/lockd.h |    3 ++-
> > >  4 files changed, 7 insertions(+), 12 deletions(-)
> > > 
> > > diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> > > index 006a832..8cfb9da 100644
> > > --- a/fs/lockd/svc4proc.c
> > > +++ b/fs/lockd/svc4proc.c
> > > @@ -99,7 +99,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
> > >  		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
> > >  
> > >  	/* Now check for conflicting locks */
> > > -	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
> > > +	resp->status = nlmsvc_testlock(rqstp, file, host, &argp->lock, &resp->lock, &resp->cookie);
> > >  	if (resp->status == nlm_drop_reply)
> > >  		rc = rpc_drop_reply;
> > >  	else
> > > diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> > > index 81aca85..f40afb3 100644
> > > --- a/fs/lockd/svclock.c
> > > +++ b/fs/lockd/svclock.c
> > > @@ -460,8 +460,8 @@ out:
> > >   */
> > >  __be32
> > >  nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> > > -		struct nlm_lock *lock, struct nlm_lock *conflock,
> > > -		struct nlm_cookie *cookie)
> > > +		struct nlm_host *host, struct nlm_lock *lock,
> > > +		struct nlm_lock *conflock, struct nlm_cookie *cookie)
> > >  {
> > >  	struct nlm_block 	*block = NULL;
> > >  	int			error;
> > > @@ -479,16 +479,10 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> > >  
> > >  	if (block == NULL) {
> > >  		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
> > > -		struct nlm_host	*host;
> > >  
> > >  		if (conf == NULL)
> > >  			return nlm_granted;
> > > -		/* Create host handle for callback */
> > > -		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
> > > -		if (host == NULL) {
> > > -			kfree(conf);
> > > -			return nlm_lck_denied_nolocks;
> > > -		}
> > > +		nlm_get_host(host);
> > >  		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
> > >  		if (block == NULL) {
> > >  			kfree(conf);
> > 
> > By the way, it'd seem clearer if nlmsvc_create_block() did the job of
> > taking whatever reference it needed on "host" itself.
> > 
> 
> That does seem like the best thing to do here...
> 
> > Seems like you could do the same for nlm_alloc_host() as well.
> > 
> > --b.
> > 
> > commit cc8c1b0a6514c670b1ab568241210bbdbece7923
> > Author: J. Bruce Fields <bfields@citi.umich.edu>
> > Date:   Tue Jul 15 15:05:45 2008 -0400
> > 
> >     lockd: get host reference in nlmsvc_create_block() instead of callers
> >     
> >     As it is it looks like there's an obvious reference count leak until you
> >     track down the definition of nlm_alloc_host() and see that it's
> >     guaranteed to consume a reference, success or failure.
> >     
> 
> I'm not sure I follow this. I don't see an nlm_alloc_host().  Do you mean
> nlm_alloc_call()?

Whoops, yes.

> If so, then it looks like it should only consume a
> reference on failure (when signaled).

It only has an explicit nlm_release_host() in that case, but in the
other case it exits having stored a pointer in a_host which will
eventually have nlm_release_host() called on it.

So I'd say it has "consumed" (either stored, or thrown away) one
reference in either case.

--b.

> 
> >     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> > index 92c49d7..80d4f2e 100644
> > --- a/fs/lockd/svclock.c
> > +++ b/fs/lockd/svclock.c
> > @@ -180,6 +180,7 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
> >  	struct nlm_block	*block;
> >  	struct nlm_rqst		*call = NULL;
> >  
> > +	nlm_get_host(host);
> >  	call = nlm_alloc_call(host);
> >  	if (call == NULL)
> >  		return NULL;
> > @@ -380,8 +381,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
> >  	 */
> >  	block = nlmsvc_lookup_block(file, lock);
> >  	if (block == NULL) {
> > -		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
> > -					    lock, cookie);
> > +		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
> >  		ret = nlm_lck_denied_nolocks;
> >  		if (block == NULL)
> >  			goto out;
> > @@ -476,7 +476,6 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
> >  
> >  		if (conf == NULL)
> >  			return nlm_granted;
> > -		nlm_get_host(host);
> >  		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
> >  		if (block == NULL) {
> >  			kfree(conf);
> 
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
