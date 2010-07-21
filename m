From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #2)
Date: Tue, 20 Jul 2010 22:09:36 -0400
Message-ID: <20100721020936.GA25684@fieldses.org>
References: <1279649422-23797-1-git-send-email-jlayton@redhat.com>
 <20100720220605.GA15024@fieldses.org>
 <20100720185714.71538ad5@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58808 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762021Ab0GUCKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 22:10:19 -0400
In-Reply-To: <20100720185714.71538ad5-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 06:57:14PM -0400, Jeff Layton wrote:
> On Tue, 20 Jul 2010 18:06:06 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > (Re-adding linux-nfs cc):
> > 
> > On Tue, Jul 20, 2010 at 02:10:22PM -0400, Jeff Layton wrote:
> > > This patch should replace the other patches that I proposed to make
> > > sure that each sv_permsock entry holds a lockd refrence.
> > > 
> > > Right now, nfsd keeps a lockd reference for each socket that it has
> > > open. This is unnecessary and complicates the error handling on
> > > startup and shutdown. Change it to just do a lockd_up when starting
> > > the first nfsd thread just do a single lockd_down when taking down the
> > > last nfsd thread. Because of the strange way the sv_count is handled
> > > this requires an extra flag to tell whether the nfsd_serv holds a
> > > reference for lockd or not.
> > 
> > OK, thanks.  This doesn't fix everything, but it looks like an
> > improvement.  Applying for 2.6.36.
> > 
> > > This patch also changes the error handling in nfsd_create_serv a
> > > bit too. There doesn't seem to be any need to reset the nfssvc_boot
> > > time if the nfsd startup failed.
> > > 
> > > Note though that this does change the user-visible behavior slightly.
> > > Today when someone writes a text socktype and port to the portlist file
> > > prior to starting nfsd, lockd is not started when nfsd threads are
> > > brought up. With this change, it will be started any time that
> > > the nfsd_serv is created. I'm making the assumption that that's not a
> > > problem. If it is then we'll need to take a different approach to fixing
> > > this.
> > 
> > (But with this last paragraph deleted, since it no longer applies?)
> > 
> > --b.
> > 
> 
> Ahh yeah, my bad. This patch was intended as more of an RFC than a
> "please apply" :). I just spun it up this earlier today.
> 
> You'll probably want "try #3" too which fixes a bug with the
> nfsd_lockd_up flag handling. If it's ok with you, I'll resend tomorrow,
> cc linux-nfs with a fixed description.

Erp, OK.  I haven't pushed that out yet, so OK.

--b.

> 
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  fs/nfsd/nfsctl.c |   10 ----------
> > >  fs/nfsd/nfssvc.c |   27 ++++++++++++++-------------
> > >  2 files changed, 14 insertions(+), 23 deletions(-)
> > > 
> > > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > > index 9e8645a..b1c5be8 100644
> > > --- a/fs/nfsd/nfsctl.c
> > > +++ b/fs/nfsd/nfsctl.c
> > > @@ -949,15 +949,8 @@ static ssize_t __write_ports_addfd(char *buf)
> > >  	if (err != 0)
> > >  		return err;
> > >  
> > > -	err = lockd_up();
> > > -	if (err != 0) {
> > > -		svc_destroy(nfsd_serv);
> > > -		return err;
> > > -	}
> > > -
> > >  	err = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
> > >  	if (err < 0) {
> > > -		lockd_down();
> > >  		svc_destroy(nfsd_serv);
> > >  		return err;
> > >  	}
> > > @@ -982,9 +975,6 @@ static ssize_t __write_ports_delfd(char *buf)
> > >  	if (nfsd_serv != NULL)
> > >  		len = svc_sock_names(nfsd_serv, buf,
> > >  					SIMPLE_TRANSACTION_LIMIT, toclose);
> > > -	if (len >= 0)
> > > -		lockd_down();
> > > -
> > >  	kfree(toclose);
> > >  	return len;
> > >  }
> > > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > > index a06ea99..c4d9cbf 100644
> > > --- a/fs/nfsd/nfssvc.c
> > > +++ b/fs/nfsd/nfssvc.c
> > > @@ -25,6 +25,7 @@
> > >  extern struct svc_program	nfsd_program;
> > >  static int			nfsd(void *vrqstp);
> > >  struct timeval			nfssvc_boot;
> > > +static bool			nfsd_lockd_up;
> > >  
> > >  /*
> > >   * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
> > > @@ -183,9 +184,10 @@ int nfsd_nrthreads(void)
> > >  static void nfsd_last_thread(struct svc_serv *serv)
> > >  {
> > >  	/* When last nfsd thread exits we need to do some clean-up */
> > > -	struct svc_xprt *xprt;
> > > -	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list)
> > > +	if (nfsd_lockd_up) {
> > >  		lockd_down();
> > > +		nfsd_lockd_up = false;
> > > +	}
> > >  	nfsd_serv = NULL;
> > >  	nfsd_racache_shutdown();
> > >  	nfs4_state_shutdown();
> > > @@ -267,10 +269,9 @@ int nfsd_create_serv(void)
> > >  	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
> > >  				      nfsd_last_thread, nfsd, THIS_MODULE);
> > >  	if (nfsd_serv == NULL)
> > > -		err = -ENOMEM;
> > > -	else
> > > -		set_max_drc();
> > > +		return -ENOMEM;
> > >  
> > > +	set_max_drc();
> > >  	do_gettimeofday(&nfssvc_boot);		/* record boot time */
> > >  	return err;
> > >  }
> > > @@ -286,19 +287,11 @@ static int nfsd_init_socks(int port)
> > >  	if (error < 0)
> > >  		return error;
> > >  
> > > -	error = lockd_up();
> > > -	if (error < 0)
> > > -		return error;
> > > -
> > >  	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
> > >  					SVC_SOCK_DEFAULTS);
> > >  	if (error < 0)
> > >  		return error;
> > >  
> > > -	error = lockd_up();
> > > -	if (error < 0)
> > > -		return error;
> > > -
> > >  	return 0;
> > >  }
> > >  
> > > @@ -395,6 +388,12 @@ nfsd_svc(unsigned short port, int nrservs)
> > >  	error =	nfsd_racache_init(2*nrservs);
> > >  	if (error<0)
> > >  		goto out;
> > > +
> > > +	error = lockd_up();
> > > +	if (error != 0)
> > > +		goto out;
> > > +	nfsd_lockd_up = true;
> > > +
> > >  	error = nfs4_state_start();
> > >  	if (error)
> > >  		goto out;
> > > @@ -422,6 +421,8 @@ shutdown_state:
> > >  	if (error < 0)
> > >  		nfs4_state_shutdown();
> > >  out:
> > > +	if (nfsd_lockd_up && error < 0)
> > > +		lockd_down();
> 		^^^^^^^
> This is the bug -- nfsd_lockd_up needs to be set to "false" here.
> 
> > >  	mutex_unlock(&nfsd_mutex);
> > >  	return error;
> > >  }
> > > -- 
> > > 1.5.5.6
> > > 
> 
> Thanks,
> -- 
> Jeff Layton <jlayton@redhat.com>
