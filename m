Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54610 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752469AbdJTSyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 14:54:38 -0400
Date: Fri, 20 Oct 2017 14:54:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Vasily Averin <vvs@virtuozzo.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Scott Mayhew <smayhew@redhat.com>, stable@vger.kernel.org
Subject: Re: [PATCH v2] lockd: double unregister of inetaddr notifiers
Message-ID: <20171020185437.GC15211@fieldses.org>
References: <a0d2108f-9886-3e3e-8d39-536caa72d81d@virtuozzo.com>
 <1508519017.5572.46.camel@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508519017.5572.46.camel@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 3.15 with a stable cc.

--b.

On Fri, Oct 20, 2017 at 01:03:37PM -0400, Jeff Layton wrote:
> On Fri, 2017-10-20 at 17:33 +0300, Vasily Averin wrote:
> > v2: reported to stable@ because it fixes backported patch.
> > 
> > lockd_up() can call lockd_unregister_notifiers twice:
> > inside lockd_start_svc() when it calls lockd_svc_exit_thread()
> > and then in error path of lockd_up()
> > 
> > Patch forces lockd_start_svc() to unregister notifiers in all error cases
> > and removes extra unregister in error path of lockd_up().
> > 
> > Fixes: cb7d224f82e4 "lockd: unregister notifier blocks if the service ..."
> > Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> > ---
> >  fs/lockd/svc.c | 20 +++++++++-----------
> >  1 file changed, 9 insertions(+), 11 deletions(-)
> > 
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index b995bdc..f04ecfc 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> > @@ -369,6 +369,7 @@ static int lockd_start_svc(struct svc_serv *serv)
> >  		printk(KERN_WARNING
> >  			"lockd_up: svc_rqst allocation failed, error=%d\n",
> >  			error);
> > +		lockd_unregister_notifiers();
> >  		goto out_rqst;
> >  	}
> >  
> > @@ -459,13 +460,16 @@ int lockd_up(struct net *net)
> >  	}
> >  
> >  	error = lockd_up_net(serv, net);
> > -	if (error < 0)
> > -		goto err_net;
> > +	if (error < 0) {
> > +		lockd_unregister_notifiers();
> > +		goto err_put;
> > +	}
> >  
> >  	error = lockd_start_svc(serv);
> > -	if (error < 0)
> > -		goto err_start;
> > -
> > +	if (error < 0) {
> > +		lockd_down_net(serv, net);
> > +		goto err_put;
> > +	}
> >  	nlmsvc_users++;
> >  	/*
> >  	 * Note: svc_serv structures have an initial use count of 1,
> > @@ -476,12 +480,6 @@ int lockd_up(struct net *net)
> >  err_create:
> >  	mutex_unlock(&nlmsvc_mutex);
> >  	return error;
> > -
> > -err_start:
> > -	lockd_down_net(serv, net);
> > -err_net:
> > -	lockd_unregister_notifiers();
> > -	goto err_put;
> >  }
> >  EXPORT_SYMBOL_GPL(lockd_up);
> >  
> 
> I think this looks right. I really do hate the way that the notifier
> handling is sprinkled all over the place in this code (not a comment on
> your patch so much as the lockd code in general). I don't see a better
> way to do it right offhand though.
> 
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
