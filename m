Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:44214 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbaIELnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 07:43:02 -0400
Received: by mail-qc0-f179.google.com with SMTP id l6so11879456qcy.38
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 04:43:01 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 07:43:00 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 5/5] nfsd: pass extra info in env vars to upcalls to
 allow for early grace period end
Message-ID: <20140905074300.7d8d06f9@tlielax.poochiereds.net>
In-Reply-To: <20140904195914.GD14576@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<1408473509-14010-6-git-send-email-jlayton@primarydata.com>
	<20140904195914.GD14576@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 15:59:14 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Aug 19, 2014 at 02:38:29PM -0400, Jeff Layton wrote:
> > In order to support lifting the grace period early, we must tell
> > nfsdcltrack what sort of client the "create" upcall is for. We can't
> > reliably tell if a v4.0 client has completed reclaiming, so we can only
> > lift the grace period once all the v4.1+ clients have issued a
> > RECLAIM_COMPLETE and if there are no v4.0 clients.
> 
> We really only care about 4.0 vs 4.1 clients.  Maybe
> NFSDCLTRACK_CLIENT_WILL_RECLAIM_COMPLETE=Y|N would be better.
> 
> --b.
> 

We have v4.2 in the queue now, and v4.3 will eventually come later.
Maybe v4.4 or v4.5 will change how recovery works? I figured it was
better to pass down more specific info and let userland sort out
what to do with it.

That said, if you think that a simple y/n flag is better, then I'll go
with that.

> > 
> > Also, in order to lift the grace period, we have to tell userland when
> > the grace period started so that it can tell whether a RECLAIM_COMPLETE
> > has been issued for each client since then.
> > 
> > Since this is all optional info, we pass it along in environment
> > variables to the "init" and "create" upcalls. By doing this, we don't
> > need to revise the upcall format. The UMH upcall can simply make use of
> > this info if it happens to be present. If it's not then it can just
> > avoid lifting the grace period early.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4recover.c | 90 ++++++++++++++++++++++++++++++++++++++++++++-------
> >  fs/nfsd/nfs4state.c   |  4 +--
> >  2 files changed, 80 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index a0d2ba956a3f..2b61bcd92b58 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -1062,6 +1062,8 @@ MODULE_PARM_DESC(cltrack_legacy_disable,
> >  
> >  #define LEGACY_TOPDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_TOPDIR="
> >  #define LEGACY_RECDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_RECDIR="
> > +#define CLIENT_MINORVERS_ENV_PREFIX "NFSDCLTRACK_CLIENT_MINORVERSION="
> > +#define GRACE_START_ENV_PREFIX "NFSDCLTRACK_GRACE_START="
> >  
> >  static char *
> >  nfsd4_cltrack_legacy_topdir(void)
> > @@ -1126,10 +1128,60 @@ nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
> >  	return result;
> >  }
> >  
> > +static char *
> > +nfsd4_cltrack_client_minorversion(struct nfs4_client *clp)
> > +{
> > +	int copied;
> > +	size_t len;
> > +	char *result;
> > +
> > +	/* prefix + max width of integer string + terminating NULL */
> > +	len = strlen(CLIENT_MINORVERS_ENV_PREFIX) + 10 + 1;
> > +
> > +	result = kmalloc(len, GFP_KERNEL);
> > +	if (!result)
> > +		return result;
> > +
> > +	copied = snprintf(result, len, CLIENT_MINORVERS_ENV_PREFIX "%u",
> > +				clp->cl_minorversion);
> > +	if (copied >= len) {
> > +		/* just return nothing if output was truncated */
> > +		kfree(result);
> > +		return NULL;
> > +	}
> > +
> > +	return result;
> > +}
> > +
> > +static char *
> > +nfsd4_cltrack_grace_start(time_t grace_start)
> > +{
> > +	int copied;
> > +	size_t len;
> > +	char *result;
> > +
> > +	/* prefix + max width of int64_t string + terminating NULL */
> > +	len = strlen(GRACE_START_ENV_PREFIX) + 22 + 1;
> > +
> > +	result = kmalloc(len, GFP_KERNEL);
> > +	if (!result)
> > +		return result;
> > +
> > +	copied = snprintf(result, len, GRACE_START_ENV_PREFIX "%ld",
> > +				grace_start);
> > +	if (copied >= len) {
> > +		/* just return nothing if output was truncated */
> > +		kfree(result);
> > +		return NULL;
> > +	}
> > +
> > +	return result;
> > +}
> > +
> >  static int
> > -nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
> > +nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *env0, char *env1)
> >  {
> > -	char *envp[2];
> > +	char *envp[3];
> >  	char *argv[4];
> >  	int ret;
> >  
> > @@ -1140,10 +1192,12 @@ nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
> >  
> >  	dprintk("%s: cmd: %s\n", __func__, cmd);
> >  	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
> > -	dprintk("%s: legacy: %s\n", __func__, legacy ? legacy : "(null)");
> > +	dprintk("%s: env0: %s\n", __func__, env0 ? env0 : "(null)");
> > +	dprintk("%s: env1: %s\n", __func__, env1 ? env1 : "(null)");
> >  
> > -	envp[0] = legacy;
> > -	envp[1] = NULL;
> > +	envp[0] = env0;
> > +	envp[1] = env1;
> > +	envp[2] = NULL;
> >  
> >  	argv[0] = (char *)cltrack_prog;
> >  	argv[1] = cmd;
> > @@ -1187,28 +1241,40 @@ bin_to_hex_dup(const unsigned char *src, int srclen)
> >  }
> >  
> >  static int
> > -nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
> > +nfsd4_umh_cltrack_init(struct net *net)
> >  {
> > +	int ret;
> > +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > +	char *grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
> > +
> >  	/* XXX: The usermode helper s not working in container yet. */
> >  	if (net != &init_net) {
> >  		WARN(1, KERN_ERR "NFSD: attempt to initialize umh client "
> >  			"tracking in a container!\n");
> >  		return -EINVAL;
> >  	}
> > -	return nfsd4_umh_cltrack_upcall("init", NULL, NULL);
> > +
> > +	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
> > +	kfree(grace_start);
> > +	return ret;
> >  }
> >  
> >  static void
> >  nfsd4_umh_cltrack_create(struct nfs4_client *clp)
> >  {
> > -	char *hexid;
> > +	char *hexid, *minorvers, *grace_start;
> > +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> >  
> >  	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> >  	if (!hexid) {
> >  		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> >  		return;
> >  	}
> > -	nfsd4_umh_cltrack_upcall("create", hexid, NULL);
> > +	minorvers = nfsd4_cltrack_client_minorversion(clp);
> > +	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
> > +	nfsd4_umh_cltrack_upcall("create", hexid, minorvers, grace_start);
> > +	kfree(minorvers);
> > +	kfree(grace_start);
> >  	kfree(hexid);
> >  }
> >  
> > @@ -1222,7 +1288,7 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
> >  		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> >  		return;
> >  	}
> > -	nfsd4_umh_cltrack_upcall("remove", hexid, NULL);
> > +	nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL);
> >  	kfree(hexid);
> >  }
> >  
> > @@ -1238,7 +1304,7 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
> >  		return -ENOMEM;
> >  	}
> >  	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
> > -	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy);
> > +	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
> >  	kfree(legacy);
> >  	kfree(hexid);
> >  	return ret;
> > @@ -1252,7 +1318,7 @@ nfsd4_umh_cltrack_grace_done(struct nfsd_net *nn)
> >  
> >  	sprintf(timestr, "%ld", nn->boot_time);
> >  	legacy = nfsd4_cltrack_legacy_topdir();
> > -	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy);
> > +	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy, NULL);
> >  	kfree(legacy);
> >  }
> >  
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 21becb29dae1..5b04353bf2ec 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -6342,10 +6342,10 @@ nfs4_state_start_net(struct net *net)
> >  	ret = nfs4_state_create_net(net);
> >  	if (ret)
> >  		return ret;
> > -	nfsd4_client_tracking_init(net);
> >  	nn->boot_time = get_seconds();
> > -	locks_start_grace(net, &nn->nfsd4_manager);
> >  	nn->grace_ended = false;
> > +	locks_start_grace(net, &nn->nfsd4_manager);
> > +	nfsd4_client_tracking_init(net);
> >  	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
> >  	       nn->nfsd4_grace, net);
> >  	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
