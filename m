Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab3KLRoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 12:44:37 -0500
Date: Tue, 12 Nov 2013 12:44:34 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>
Subject: Re: [PATCH 1/2] sunrpc: create a new dummy pipe for gssd to hold
 open
Message-ID: <20131112124434.4e1c36b0@tlielax.poochiereds.net>
In-Reply-To: <1384277770.4779.27.camel@leira.trondhjem.org>
References: <1384261225-28559-1-git-send-email-jlayton@redhat.com>
	<1384261225-28559-2-git-send-email-jlayton@redhat.com>
	<1384277770.4779.27.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 12 Nov 2013 17:36:15 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-11-12 at 08:00 -0500, Jeff Layton wrote:
> > rpc.gssd will naturally hold open any pipe named */clnt*/gssd that shows
> > up under rpc_pipefs. That behavior gives us a reliable mechanism to tell
> > whether it's actually running or not.
> > 
> > Create a new toplevel "dummy" directory in rpc_pipefs when it's mounted.
> > Under that directory create another directory called "clntXX", and then
> > within that a pipe called "gssd".
> > 
> > We'll never send an upcall along that pipe, and any downcall written to
> > it will just return -EINVAL.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/netns.h    |  1 +
> >  net/sunrpc/rpc_pipe.c | 84 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 85 insertions(+)
> > 
> > diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
> > index 779742c..6b82968 100644
> > --- a/net/sunrpc/netns.h
> > +++ b/net/sunrpc/netns.h
> > @@ -15,6 +15,7 @@ struct sunrpc_net {
> >  
> >  	struct super_block *pipefs_sb;
> >  	struct mutex pipefs_sb_lock;
> > +	struct dentry *gssd_dummy;
> >  
> >  	struct list_head all_clients;
> >  	spinlock_t rpc_client_lock;
> > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > index f94567b..1c54de6 100644
> > --- a/net/sunrpc/rpc_pipe.c
> > +++ b/net/sunrpc/rpc_pipe.c
> > @@ -1168,6 +1168,7 @@ enum {
> >  	RPCAUTH_nfsd4_cb,
> >  	RPCAUTH_cache,
> >  	RPCAUTH_nfsd,
> > +	RPCAUTH_dummy,
> >  	RPCAUTH_RootEOF
> >  };
> >  
> > @@ -1204,6 +1205,10 @@ static const struct rpc_filelist files[] = {
> >  		.name = "nfsd",
> >  		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
> >  	},
> > +	[RPCAUTH_dummy] = {
> > +		.name = "dummy",
> 
> "gssd" would be nicer.
> 

Ha! That's what my original patch had, but I thought that made it look
too legit. I can respin and change it though if you like...

> > +		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
> > +	},
> >  };
> >  
> >  /*
> > @@ -1253,6 +1258,80 @@ void rpc_put_sb_net(const struct net *net)
> >  }
> >  EXPORT_SYMBOL_GPL(rpc_put_sb_net);
> >  
> > +static const struct rpc_filelist dummy_clnt_dir[] = {
> > +	[0] = {
> > +		.name = "clntXX",
> > +		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
> > +	},
> > +};
> > +
> > +static ssize_t
> > +dummy_downcall(struct file *filp, const char __user *src, size_t len)
> > +{
> > +	return -EINVAL;
> > +}
> > +
> > +static const struct rpc_pipe_ops dummy_pipe_ops = {
> > +	.upcall		= rpc_pipe_generic_upcall,
> > +	.downcall	= dummy_downcall,
> > +};
> > +
> > +/**
> > + * rpc_gssd_dummy_populate - create a dummy gssd pipe
> > + * @root: root of the rpc_pipefs filesystem
> > + *
> > + * Create a dummy set of directories and a pipe that gssd can hold open to
> > + * indicate that it is up and running.
> > + */
> > +static struct dentry *
> > +rpc_gssd_dummy_populate(struct dentry *root)
> > +{
> > +	int ret = 0;
> > +	struct dentry *gssd_dentry;
> > +	struct dentry *clnt_dentry = NULL;
> > +	struct dentry *pipe_dentry = NULL;
> > +	struct rpc_pipe *pipe_data = NULL;
> > +	struct qstr q = QSTR_INIT(files[RPCAUTH_dummy].name,
> > +				  strlen(files[RPCAUTH_dummy].name));
> > +
> > +	/* We should never get this far if "gssd" doesn't exist */
> > +	gssd_dentry = d_hash_and_lookup(root, &q);
> > +	if (!gssd_dentry)
> > +		return ERR_PTR(-ENOENT);
> > +
> > +	ret = rpc_populate(gssd_dentry, dummy_clnt_dir, 0, 1, NULL);
> > +	if (ret) {
> > +		pipe_dentry = ERR_PTR(ret);
> > +		goto out;
> > +	}
> > +
> > +	pipe_data = rpc_mkpipe_data(&dummy_pipe_ops, 0);
> > +	if (IS_ERR(pipe_data)) {
> > +		pipe_dentry = ERR_CAST(pipe_data);
> > +		pipe_data = NULL;
> > +		goto out;
> > +	}
> > +
> > +	q.name = dummy_clnt_dir[0].name;
> > +	q.len = strlen(dummy_clnt_dir[0].name);
> > +	clnt_dentry = d_hash_and_lookup(gssd_dentry, &q);
> > +	if (!clnt_dentry) {
> > +		pipe_dentry = ERR_PTR(-ENOENT);
> > +		goto out;
> > +	}
> > +
> > +	pipe_dentry = rpc_mkpipe_dentry(clnt_dentry, "gssd", NULL, pipe_data);
> > +	if (IS_ERR(pipe_dentry))
> > +		goto out;
> > +
> > +	pipe_data = NULL;
> > +out:
> > +	rpc_destroy_pipe_data(pipe_data);
> > +	dput(clnt_dentry);
> > +	dput(gssd_dentry);
> > +	return pipe_dentry;
> > +}
> > +
> >  static int
> >  rpc_fill_super(struct super_block *sb, void *data, int silent)
> >  {
> > @@ -1275,6 +1354,11 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
> >  		return -ENOMEM;
> >  	if (rpc_populate(root, files, RPCAUTH_lockd, RPCAUTH_RootEOF, NULL))
> >  		return -ENOMEM;
> > +
> > +	sn->gssd_dummy = rpc_gssd_dummy_populate(root);
> > +	if (IS_ERR(sn->gssd_dummy))
> > +		return PTR_ERR(sn->gssd_dummy);
> > +
> >  	dprintk("RPC:       sending pipefs MOUNT notification for net %p%s\n",
> >  		net, NET_NAME(net));
> >  	mutex_lock(&sn->pipefs_sb_lock);
> 


-- 
Jeff Layton <jlayton@redhat.com>
