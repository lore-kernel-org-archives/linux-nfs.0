From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] SUNRPC: have soft RPC tasks return -ETIMEDOUT instead
	of -EIO on major connect timeout
Date: Sat, 29 Mar 2008 15:24:24 -0400
Message-ID: <20080329152424.6857ee86@tleilax.poochiereds.net>
References: <1206794957-17010-1-git-send-email-jlayton@redhat.com>
	<1206809051.8480.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1206809051.8480.33.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 29 Mar 2008 12:44:11 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Sat, 2008-03-29 at 08:49 -0400, Jeff Layton wrote:
> > NFSv4 background mounts do not currently work correctly. While we could
> > try to fix this in userspace, I think it's really a kernel problem...
> > 
> > When a soft RPC tasks experiences a major timeout during a connection
> > attempt, it does an rpc_exit with a return code of -EIO. For NFSv4
> > mounts, this makes the mount() syscall return -EIO. mount.nfs4 then
> > interprets that as a "permanent" error, and won't attempt a background
> > mount when bg is specified. Fix this by making call_timeout() do the
> > rpc_exit() with an error of -ETIMEDOUT.
> > 
> > This fixes the background mount issue, but does make other syscalls
> > on soft mounts return ETIMEDOUT instead of EIO in this situation.
> > 
> > Comments welcome.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/clnt.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index 8c6a7f1..b6d409e 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1162,7 +1162,7 @@ call_timeout(struct rpc_task *task)
> >  	if (RPC_IS_SOFT(task)) {
> >  		printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
> >  				clnt->cl_protname, clnt->cl_server);
> > -		rpc_exit(task, -EIO);
> > +		rpc_exit(task, -ETIMEDOUT);
> >  		return;
> >  	}
> 
> While that may be acceptable for the mount() syscall, I don't think
> POSIX applications are quite ready to deal with ETIMEDOUT as an error
> for stat() or chdir().
> 

Ugh. Good point.

> Userland has the clnt_geterr() function that returns more detailed 'RPC
> level' errors. While that 'error function call' approach doesn't work in
> a multi-threaded environment, we might still be able to add the
> equivalent of a pointer to an 'rpc_err' structure to the rpc_task, and
> then have functions like call_timeout() (and especially call_verify()!)
> fill in more detailed error info if that pointer is non-zero?
>

I'm not sure we really need this, do we?

Should it really be the business of the RPC layer to sanitize the
tk_status like this? It seems like the NFS layer ought to be
translating "illegal" errors from the RPC layer into more generic ones
where needed rather than relying on the RPC layer to do it, though
maybe I'm not thinking about the RPC layer in the right way here...

Thanks,
--
Jeff Layton <jlayton@redhat.com>
