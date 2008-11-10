From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/9] rpc: add an rpc_pipe_open method
Date: Mon, 10 Nov 2008 15:37:57 -0500
Message-ID: <20081110203757.GI19053@fieldses.org>
References: <20081109204621.GD27376@fieldses.org> <1226264683-28650-1-git-send-email-bfields@citi.umich.edu> <1226264683-28650-2-git-send-email-bfields@citi.umich.edu> <1226264683-28650-3-git-send-email-bfields@citi.umich.edu> <1226264683-28650-4-git-send-email-bfields@citi.umich.edu> <1226264683-28650-5-git-send-email-bfields@citi.umich.edu> <1226349322.7599.59.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38165 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753928AbYKJUh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 15:37:59 -0500
In-Reply-To: <1226349322.7599.59.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 03:35:22PM -0500, Trond Myklebust wrote:
> On Sun, 2008-11-09 at 16:04 -0500, J. Bruce Fields wrote:
> > We want to transition to a new gssd upcall which is text-based and more
> > easily extensible.
> > 
> > To simplify upgrades, as well as testing and debugging, it will help if
> > we can upgrade gssd (to a version which understands the new upcall)
> > without having to choose at boot (or module-load) time whether we want
> > the new or the old upcall.
> > 
> > We will do this by providing two different pipes: one named, as
> > currently, after the mechanism (normally "krb5"), and supporting the
> > old upcall.  One named "gssd" and supporting the new upcall version.
> > 
> > We allow gssd to indicate which version it supports by its choice of
> > which pipe to open.
> > 
> > As we have no interest in supporting *simultaneous* use of both
> > versions, we'll forbid opening both pipes at the same time.
> > 
> > So, add a new pipe_open callback to the rpc_pipefs api, which the gss
> > code can use to track which pipes have been open, and to refuse opens of
> > incompatible pipes.
> > 
> > We only need this to be called on the first open of a given pipe.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  include/linux/sunrpc/rpc_pipe_fs.h |    1 +
> >  net/sunrpc/rpc_pipe.c              |   21 ++++++++++++++-------
> >  2 files changed, 15 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
> > index 51b977a..cea764c 100644
> > --- a/include/linux/sunrpc/rpc_pipe_fs.h
> > +++ b/include/linux/sunrpc/rpc_pipe_fs.h
> > @@ -15,6 +15,7 @@ struct rpc_pipe_ops {
> >  	ssize_t (*upcall)(struct file *, struct rpc_pipe_msg *, char __user *, size_t);
> >  	ssize_t (*downcall)(struct file *, const char __user *, size_t);
> >  	void (*release_pipe)(struct inode *);
> > +	int (*open_pipe)(struct inode *);
> >  	void (*destroy_msg)(struct rpc_pipe_msg *);
> >  };
> >  
> > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > index 23a2b8f..4171ab7 100644
> > --- a/net/sunrpc/rpc_pipe.c
> > +++ b/net/sunrpc/rpc_pipe.c
> > @@ -169,16 +169,23 @@ static int
> >  rpc_pipe_open(struct inode *inode, struct file *filp)
> >  {
> >  	struct rpc_inode *rpci = RPC_I(inode);
> > +	int first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
> >  	int res = -ENXIO;
> >  
> >  	mutex_lock(&inode->i_mutex);
> > -	if (rpci->ops != NULL) {
> > -		if (filp->f_mode & FMODE_READ)
> > -			rpci->nreaders ++;
> > -		if (filp->f_mode & FMODE_WRITE)
> > -			rpci->nwriters ++;
> > -		res = 0;
> > +	if (rpci->ops == NULL)
> > +		goto out;
> > +	if (first_open && rpci->ops->open_pipe) {
> > +		res = rpci->ops->open_pipe(inode);
> > +		if (res)
> > +			goto out;
> >  	}
> > +	if (filp->f_mode & FMODE_READ)
> > +		rpci->nreaders++;
> > +	if (filp->f_mode & FMODE_WRITE)
> > +		rpci->nwriters++;
> > +	res = 0;
> > +out:
> 
> BTW: This is racy. You have to set first_open _after_ you take the
> inode->i_mutex.

Whoops!  Good catch, thanks--fixed.

--b.

> 
> >  	mutex_unlock(&inode->i_mutex);
> >  	return res;
> >  }
> > @@ -748,7 +755,7 @@ rpc_rmdir(struct dentry *dentry)
> >   * @name: name of pipe
> >   * @private: private data to associate with the pipe, for the caller's use
> >   * @ops: operations defining the behavior of the pipe: upcall, downcall,
> > - *	release_pipe, and destroy_msg.
> > + *	release_pipe, open_pipe, and destroy_msg.
> >   * @flags: rpc_inode flags
> >   *
> >   * Data is made available for userspace to read by calls to
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
