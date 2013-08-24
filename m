Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547Ab3HXOac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Aug 2013 10:30:32 -0400
Date: Sat, 24 Aug 2013 10:30:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Jan Stancek <jstancek@redhat.com>, ssorce@redhat.com
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
Message-ID: <20130824103028.29d6d839@tlielax.poochiereds.net>
In-Reply-To: <20130824124314.GD18084@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
	<20130823231843.GB18084@fieldses.org>
	<20130824124314.GD18084@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 24 Aug 2013 08:43:14 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Aug 23, 2013 at 07:18:43PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 22, 2013 at 04:10:13PM -0400, Jeff Layton wrote:
> > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > 
> > > v2: added pipe_dir_name field to nfsacl program to fix v3+krb5
> > >     (Should we add pipe_dir_name fields to other programs too?).
> > > 
> > > v3: Drop changes to gss_encode_v1_msg. They don't seem to be
> > >     needed since gssd scrapes that out of the "info" file.
> > 
> > Hm.  nfsv3/krb5 is still broken for me after this patch.  I'll try to
> > figure out why....
> 
> Whoops, never mind, my client was booted to the wrong kernel, with this
> patch it does work.
> 
> --b.
> 

Whew! Ok, so I guess the only concern at this point is Simo's (valid)
point that the "nfs4_cb/" service is wrong. I'll fix that in the next
respin.

FWIW, I have to wonder whether there's any benefit to using a different
service name from "nfs/" for auxillary services (e.g. mountd, lockd,
etc). Does Solaris offer kerberized MNT or NLM? If so, what does it do?


> > 
> > --b.
> > 
> > > 
> > > Fix the upcalls to use the right service names for gssd.  The old
> > > version of the rpc.gssd upcall expects the service name to be either
> > > "nfs" or "nfs4_cb", which it will then concatenate with the server name
> > > to create a target name of nfs@<server> or nfs4_cb@<server>
> > > 
> > > Finally, make sure that we set the correct service names for lockd,
> > > statd and mountd in case we want to convert those to use rpcsec_gss at
> > > some point in the future.
> > > 
> > > Fix the upcalls to use the right service names for gssd.  The old
> > > version of the rpc.gssd upcall expects the service name to be either
> > > "nfs" or "nfs4_cb", which it will then concatenate with the server name
> > > to create a target name of nfs@<server> or nfs4_cb@<server>
> > > 
> > > Finally, make sure that we set the correct service names for lockd,
> > > statd and mountd in case we want to convert those to use rpcsec_gss at
> > > some point in the future.
> > > 
> > > Cc: Jan Stancek <jstancek@redhat.com>
> > > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > ---
> > >  fs/lockd/clntxdr.c          | 1 +
> > >  fs/lockd/mon.c              | 1 +
> > >  fs/nfs/client.c             | 1 +
> > >  fs/nfs/mount_clnt.c         | 1 +
> > >  fs/nfs/nfs3client.c         | 2 ++
> > >  fs/nfsd/nfs4callback.c      | 1 +
> > >  include/linux/sunrpc/clnt.h | 1 +
> > >  net/sunrpc/rpc_pipe.c       | 3 ++-
> > >  8 files changed, 10 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
> > > index 9a55797..18d0c34 100644
> > > --- a/fs/lockd/clntxdr.c
> > > +++ b/fs/lockd/clntxdr.c
> > > @@ -612,6 +612,7 @@ static struct rpc_stat		nlm_rpc_stats;
> > >  
> > >  const struct rpc_program	nlm_program = {
> > >  		.name		= "lockd",
> > > +		.service_name	= "nlockmgr",
> > >  		.number		= NLM_PROGRAM,
> > >  		.nrvers		= ARRAY_SIZE(nlm_versions),
> > >  		.version	= nlm_versions,
> > > diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> > > index 1812f02..1ac10f4 100644
> > > --- a/fs/lockd/mon.c
> > > +++ b/fs/lockd/mon.c
> > > @@ -606,6 +606,7 @@ static struct rpc_stat		nsm_stats;
> > >  
> > >  static const struct rpc_program nsm_program = {
> > >  		.name		= "statd",
> > > +		.service_name	= "status",
> > >  		.number		= NSM_PROGRAM,
> > >  		.nrvers		= ARRAY_SIZE(nsm_version),
> > >  		.version	= nsm_version,
> > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > > index 340b1ef..9fb1050 100644
> > > --- a/fs/nfs/client.c
> > > +++ b/fs/nfs/client.c
> > > @@ -72,6 +72,7 @@ static const struct rpc_version *nfs_version[5] = {
> > >  
> > >  const struct rpc_program nfs_program = {
> > >  	.name			= "nfs",
> > > +	.service_name		= "nfs",
> > >  	.number			= NFS_PROGRAM,
> > >  	.nrvers			= ARRAY_SIZE(nfs_version),
> > >  	.version		= nfs_version,
> > > diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> > > index 99a4528..5f1a888 100644
> > > --- a/fs/nfs/mount_clnt.c
> > > +++ b/fs/nfs/mount_clnt.c
> > > @@ -528,6 +528,7 @@ static struct rpc_stat mnt_stats;
> > >  
> > >  static const struct rpc_program mnt_program = {
> > >  	.name		= "mount",
> > > +	.service_name	= "mountd",
> > >  	.number		= NFS_MNT_PROGRAM,
> > >  	.nrvers		= ARRAY_SIZE(mnt_version),
> > >  	.version	= mnt_version,
> > > diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> > > index b3fc65e..b61de6b 100644
> > > --- a/fs/nfs/nfs3client.c
> > > +++ b/fs/nfs/nfs3client.c
> > > @@ -10,10 +10,12 @@ static const struct rpc_version *nfsacl_version[] = {
> > >  
> > >  const struct rpc_program nfsacl_program = {
> > >  	.name			= "nfsacl",
> > > +	.service_name		= "nfs",
> > >  	.number			= NFS_ACL_PROGRAM,
> > >  	.nrvers			= ARRAY_SIZE(nfsacl_version),
> > >  	.version		= nfsacl_version,
> > >  	.stats			= &nfsacl_rpcstat,
> > > +	.pipe_dir_name		= "nfs",
> > >  };
> > >  
> > >  /*
> > > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > > index 7f05cd1..2962890 100644
> > > --- a/fs/nfsd/nfs4callback.c
> > > +++ b/fs/nfsd/nfs4callback.c
> > > @@ -596,6 +596,7 @@ static struct rpc_stat cb_stats = {
> > >  #define NFS4_CALLBACK 0x40000000
> > >  static const struct rpc_program cb_program = {
> > >  	.name			= "nfs4_cb",
> > > +	.service_name		= "nfs4_cb",
> > >  	.number			= NFS4_CALLBACK,
> > >  	.nrvers			= ARRAY_SIZE(nfs_cb_version),
> > >  	.version		= nfs_cb_version,
> > > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > > index bfe11be..d902c55 100644
> > > --- a/include/linux/sunrpc/clnt.h
> > > +++ b/include/linux/sunrpc/clnt.h
> > > @@ -70,6 +70,7 @@ struct rpc_clnt {
> > >  #define RPC_MAXVERSION		4
> > >  struct rpc_program {
> > >  	const char *		name;		/* protocol name */
> > > +	const char *		service_name;	/* protocol service name */
> > >  	u32			number;		/* program number */
> > >  	unsigned int		nrvers;		/* number of versions */
> > >  	const struct rpc_version **	version;	/* version array */
> > > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > > index 406859c..83b196d 100644
> > > --- a/net/sunrpc/rpc_pipe.c
> > > +++ b/net/sunrpc/rpc_pipe.c
> > > @@ -409,7 +409,8 @@ rpc_show_info(struct seq_file *m, void *v)
> > >  	rcu_read_lock();
> > >  	seq_printf(m, "RPC server: %s\n",
> > >  			rcu_dereference(clnt->cl_xprt)->servername);
> > > -	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
> > > +	seq_printf(m, "service: %s (%d) version %d\n",
> > > +			clnt->cl_program->service_name,
> > >  			clnt->cl_prog, clnt->cl_vers);
> > >  	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
> > >  	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
> > > -- 
> > > 1.8.3.1
> > > 


-- 
Jeff Layton <jlayton@redhat.com>
