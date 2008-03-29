From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] SUNRPC: have soft RPC tasks return -ETIMEDOUT instead
	of -EIO on major connect timeout
Date: Sat, 29 Mar 2008 16:05:49 -0400
Message-ID: <1206821149.8455.13.camel@heimdal.trondhjem.org>
References: <1206794957-17010-1-git-send-email-jlayton@redhat.com>
	<1206809051.8480.33.camel@heimdal.trondhjem.org>
	<20080329152424.6857ee86@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080329152424.6857ee86@tleilax.poochiereds.net>
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


On Sat, 2008-03-29 at 15:24 -0400, Jeff Layton wrote:
> On Sat, 29 Mar 2008 12:44:11 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > Userland has the clnt_geterr() function that returns more detailed 'RPC
> > level' errors. While that 'error function call' approach doesn't work in
> > a multi-threaded environment, we might still be able to add the
> > equivalent of a pointer to an 'rpc_err' structure to the rpc_task, and
> > then have functions like call_timeout() (and especially call_verify()!)
> > fill in more detailed error info if that pointer is non-zero?
> >
> 
> I'm not sure we really need this, do we?
> 
> Should it really be the business of the RPC layer to sanitize the
> tk_status like this? It seems like the NFS layer ought to be
> translating "illegal" errors from the RPC layer into more generic ones
> where needed rather than relying on the RPC layer to do it, though
> maybe I'm not thinking about the RPC layer in the right way here...

Yes and no. The RPC error reports are sometimes more complex than what
we can fit into a single 32-bit error code. I'm thinking in particular
of the RPC_AUTH_* errors (EACCESS just doesn't do them justice), and
RPC_PROG_MISMATCH error.

In the case of RPC_PROG_MISMATCH, it would, for instance, be really
useful for the in-kernel mount code to be able to also retrieve the
'mismatch_info' structure (see RFC1831), which tells you exactly which
program versions are actually supported on that port.

An extra optional pointer to a structure in the rpc_task won't cost us
much, but could possibly provide a lot of interesting information that
we are currently ignoring.

Cheers
  Trond
