Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Thu, 1 Apr 2010 13:26:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why does each NFS mount have (at least) 2 rpc_clnt's ?
Message-ID: <20100401132619.24278811@barsoom.rdu.redhat.com>
In-Reply-To: <1270127869.3533.12.camel@localhost.localdomain>
References: <20100401084620.3475d4c0@barsoom.rdu.redhat.com>
	<1270127869.3533.12.camel@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 01 Apr 2010 09:17:49 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2010-04-01 at 08:46 -0400, Jeff Layton wrote: 
> > I'm working on an issue in an older kernel where we see occasional
> > panics when trying to refresh credentials. Here's the bug in case
> > anyone is interested:
> > 
> >     https://bugzilla.redhat.com/show_bug.cgi?id=572870
> > 
> > ...I think I understand the problem well enough now. The problem is
> > pretty complex, but the issue is that some operations are done using
> > credentials from a stateowner associated with a nfs_client, but using
> > the rpc_clnt in nfs_server->client. The two can have different
> > authtypes if there are a mix of mounts with different authtypes to the
> > same server. This problem seems to have been fixed in mainline with the
> > introduction of the auth_generic code.
> > 
> > It leaves me wondering though...what exactly is the reason for having
> > two rpc_clients per NFS mount? To clarify, I'm talking about these two,
> > which seem to be somewhat redundant:
> > 
> > nfs_server->client
> > nfs_server->nfs_client->cl_rpcclient
> > 
> > On mount, the nfs4_set_client calls nfs_get_client to search the list
> > of nfs_client structs until it finds one that matches the address, port,
> > etc of the NFS server. If one isn't found, the kernel creates one using
> > whatever authtype was requested for the mount.
> > 
> > Later, nfs_init_server_rpcclient looks at the rpc_clnt in the
> > nfs_client and copies it. If the auth pseudoflavor doesn't match
> > however, it creates a new rpc_auth for it.
> > 
> > What exactly is the point of having two rpc_clnt's? Why not just get
> > always use nfs_client->cl_rpcclient instead of nfs_server->client and
> > simply have nfs_get_client filter by authtype?
> > 
> 
> Look again at nfs_init_server_rpcclient(). The pseudoflavour is not the
> only thing that is changed. We also change the soft flag and the timeout
> properties of the server->client.
> 
> The point is that users sometimes want to specify per-mountpoint
> transport properties, and so we try to give them that possibility, while
> at the same time sharing sockets/rdma connections.
> 
> Cheers
>   Trond
> 

Ok, I think I sort of understand now. The nfs_client holds some global
state info that's common to all nfs mounts on the server so that info
has to be shared between NFS mounts. The nfs_server struct holds stuff
that's specific to a single superblock.

That said, I still am not certain I see why we want to have an rpc_clnt
that's shared between the mounts though clearly there's benefit to
sharing the xprt between them.

-- 
Jeff Layton <jlayton@redhat.com>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
