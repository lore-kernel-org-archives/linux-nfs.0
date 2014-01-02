Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbaABXLE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jan 2014 18:11:04 -0500
Date: Thu, 2 Jan 2014 18:10:55 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, simo@redhat.com, neilb@suse.de
Subject: Re: [RFC PATCH 3/5] sunrpc: wait for gssproxy to start on initial
 upcall attempt before falling back to legacy upcall
Message-ID: <20140102181055.324ed278@tlielax.poochiereds.net>
In-Reply-To: <20140102213547.GD28219@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
	<1388579314-15255-4-git-send-email-jlayton@redhat.com>
	<20140102213547.GD28219@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2 Jan 2014 16:35:47 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 01, 2014 at 07:28:32AM -0500, Jeff Layton wrote:
> > Currently, the only thing that waits for gssproxy to start is reads
> > from the use-gss-proxy procfile. That's a little odd, since nothing
> > but gssproxy itself will likely ever open that file, and all it does
> > it write to it.
> > 
> > It seems like what we really want instead is for svcrpc code to give
> > gssproxy a little time to start up in the event that some RPCs come
> > in before it's ready.
> 
> Legacy userspace will never write, so this adds an 5-second delay in
> that case.
> 
> I'd rather avoid any arbitrary timeout.
> 
> It seems to me all you need is for gss-proxy to ensure that it does the
> write to use-gss-proxy before it indicates to whoever started it that
> it's done starting.
> 
> Then as long as the init system orders gss-proxy startup before nfsd
> startup, we're good.
> 
> --b.
> 

Yep, that 5s delay on the first upcall was the part that was
questionable...

Ok, so basically the behavior you want is:

"If gssproxy is up and running by the time the first RPC comes in then
 use that. If not, then use the legacy code."

I'll respin the set with that behavior in mind. I need to do a bit of
testing with it too, so it may be a week or so before I repost.

> > 
> > Change it so that the upcall instead waits a little while for gssproxy
> > to start before giving up. If the wait times out, we go ahead and
> > disable gssproxy so that later upcalls don't delay.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/svcauth_gss.c | 28 ++++++++++------------------
> >  1 file changed, 10 insertions(+), 18 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > index 64c025e..921f388 100644
> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > @@ -1265,24 +1265,6 @@ out:
> >  
> >  DEFINE_SPINLOCK(use_gssp_lock);
> >  
> > -static bool use_gss_proxy(struct net *net)
> > -{
> > -	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> > -
> > -	if (sn->use_gss_proxy != -1)
> > -		return sn->use_gss_proxy;
> > -	spin_lock(&use_gssp_lock);
> > -	/*
> > -	 * If you wanted gss-proxy, you should have said so before
> > -	 * starting to accept requests:
> > -	 */
> > -	sn->use_gss_proxy = 0;
> > -	spin_unlock(&use_gssp_lock);
> > -	return 0;
> > -}
> > -
> > -#ifdef CONFIG_PROC_FS
> > -
> >  static int set_gss_proxy(struct net *net, int type)
> >  {
> >  	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> > @@ -1332,6 +1314,16 @@ static int wait_for_gss_proxy(struct net *net)
> >  	return ret < 0 ? ret : 0;
> >  }
> >  
> > +static bool use_gss_proxy(struct net *net)
> > +{
> > +	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> > +
> > +	if (wait_for_gss_proxy(net))
> > +		return false;
> > +	return gssp_ready(sn);
> > +}
> > +
> > +#ifdef CONFIG_PROC_FS
> >  
> >  static ssize_t write_gssp(struct file *file, const char __user *buf,
> >  			 size_t count, loff_t *ppos)
> > -- 
> > 1.8.4.2
> > 


-- 
Jeff Layton <jlayton@redhat.com>
