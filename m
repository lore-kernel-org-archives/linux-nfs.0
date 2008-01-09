From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 5/6] NLM: Convert lockd to use kthreads
Date: Wed, 9 Jan 2008 13:08:11 -0500
Message-ID: <20080109130811.6ea2cca7@tleilax.poochiereds.net>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
	<1199820798-5289-2-git-send-email-jlayton@redhat.com>
	<1199820798-5289-3-git-send-email-jlayton@redhat.com>
	<1199820798-5289-4-git-send-email-jlayton@redhat.com>
	<1199820798-5289-5-git-send-email-jlayton@redhat.com>
	<1199820798-5289-6-git-send-email-jlayton@redhat.com>
	<20080109174506.GB30523@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: akpm@linux-foundation.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbYAISIY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 13:08:24 -0500
In-Reply-To: <20080109174506.GB30523@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Jan 2008 17:45:06 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jan 08, 2008 at 02:33:17PM -0500, Jeff Layton wrote:
> > -	struct svc_serv *	serv;
> > -	int			error = 0;
> > +	struct svc_serv *serv;
> > +	struct svc_rqst *rqstp;
> > +	int		error = 0;
> >  
> >  	mutex_lock(&nlmsvc_mutex);
> >  	/*
> >  	 * Check whether we're already up and running.
> >  	 */
> > -	if (nlmsvc_pid) {
> > +	if (nlmsvc_task) {
> >  		if (proto)
> >  			error = make_socks(nlmsvc_serv, proto);
> 
> While equivalent I think it would be clener to check for nlmsvc_serv
> above as that'swhat we're passing to make_socks.  But I think the
> whole of lockd_up could use a little makeover, but that's for later.
> 

Probably so. If I respin, I'll plan to fix that too.

> >  void
> >  lockd_down(void)
> >  {
> >  	mutex_lock(&nlmsvc_mutex);
> >  	if (nlmsvc_users) {
> >  		if (--nlmsvc_users)
> >  			goto out;
> > +	} else {
> > +		printk(KERN_ERR "lockd_down: no users! task=%p\n",
> > +			nlmsvc_task);
> > +		BUG();
> >  	}
> > +	if (!nlmsvc_task) {
> > +		printk(KERN_ERR "lockd_down: no lockd running.\n");
> > +		BUG();
> >  	}
> > +	kthread_stop(nlmsvc_task);
> 
> I think all this user/foo checking here should be BUG_ONs as it's
> quite fatal errors.
> 
> e.g.
> 
> void
> lockd_down(void)
> {
>  	mutex_lock(&nlmsvc_mutex);
> 
> 	BUG_ON(!nlmsvc_task);
> 	BUG_ON(!nlmsvc_users);
> 
> 	if (!--nlmsvc_users)
> 		kthread_stop(nlmsvc_task);
> 	mutex_unlock(&nlmsvc_mutex);
> }
> 
> 
> same applies for similar checks in lockd_up aswell.
> 	

With this patch the lockd_down checks should now be BUGs. I decided
not to do that in lockd_up. If there's an error within the main
lockd loop, it can exit without being requested to do so. If someone
then calls lockd_up then the counts will be off and the check will fire.

It seems like if we're going to make the check in lockd_up be a BUG,
then we should also BUG rather than letting lockd exit prematurely.

-- 
Jeff Layton <jlayton@redhat.com>
