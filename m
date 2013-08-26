Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757272Ab3HZQux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Aug 2013 12:50:53 -0400
Date: Mon, 26 Aug 2013 12:50:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Simo Sorce <simo@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
Message-ID: <20130826165051.GF3121@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
 <1377320162.2814.331.camel@willson.li.ssimo.org>
 <20130824065706.7bf780e8@tlielax.poochiereds.net>
 <20130824124233.GC18084@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130824124233.GC18084@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 24, 2013 at 08:42:33AM -0400, J. Bruce Fields wrote:
> On Sat, Aug 24, 2013 at 06:57:06AM -0400, Jeff Layton wrote:
> > On Sat, 24 Aug 2013 00:56:02 -0400
> > Simo Sorce <simo@redhat.com> wrote:
> > 
> > > On Thu, 2013-08-22 at 16:10 -0400, Jeff Layton wrote:
> > > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > 
> > > > v2: added pipe_dir_name field to nfsacl program to fix v3+krb5
> > > >     (Should we add pipe_dir_name fields to other programs too?).
> > > > 
> > > > v3: Drop changes to gss_encode_v1_msg. They don't seem to be
> > > >     needed since gssd scrapes that out of the "info" file.
> > > > 
> > > > Fix the upcalls to use the right service names for gssd.  The old
> > > > version of the rpc.gssd upcall expects the service name to be either
> > > > "nfs" or "nfs4_cb", which it will then concatenate with the server name
> > > > to create a target name of nfs@<server> or nfs4_cb@<server>
> > > 
> > > I've never seen anyone deply keytabs with nfs4_cb/fqdn service names,
> > > what are you trying to do here exactly ?
> > > 
> > > Afaik the only service names used historically have been host/ and nfs/
> > > and in some rare cases root/
> > > 
> > > Also the patch seem to add a bunch of other 'service' names ? If you are
> > > going to kerberize those services are you going to expect admins to drop
> > > multiple keys down in the keytabs ? What is the exact intent here ?

Yeah, that seems wrong to me, if (big if) any of the other services used
gss I'd expect they'd want to authenticate to the same nfs/ principal.

> > Mostly, I'm trying to ensure that the nfsacl service uses a nfs/
> > principal to fix the immediate pain point that nfsv3+krb5 doesn't work.
> > With the rest, I was mainly trusting that Trond knew what he was
> > doing. ;)
> > 
> > I agree though...I've never seen a nfs4_cb/ principal in use, and I'm
> > not sure that we'd really get a lot of value from using a separate
> > principal for callbacks.
> 
> It's wrong, in fact: an NFSv4.0 callback is supposed to authenticate to
> the principal that performed the setclientid.

Well, but: after refamiliarizing myself with the code this morning:
really, it's irrelevant.  The server's setup_callback_client() calls
rpc_create with client_name set to the principal that performed the
setclientid.  This sets cl_principal, which results in a "target="
argument in the upcall.

(The way this is set looks hairy:

	- svcgssd case: svcgssd passes it down at the end of the
	  downcall.  It's calculated by
	  utils/gssd/svcgssd_proc.c:get_hostbased_client_name by calling
	  gss_display_name() and then changing x/y@REALM to x@y in the
	  krb5 case.  ??
	- gssproxy case: does the same transformation on the returned
	  name in gssp_accept_sec_context_upcall.

But Simo'd be the expert on whether this makes sense and what we should
do instead if not.)

--b.

> 
> --b.
> 
> > Perhaps we should just hardcode "nfs" as the
> > service= parm in the "info" file for now?
> > 
> > Longer term, I think it's time to start a serious re-think of this
> > upcall. Having to have a running daemon for this sucks, particularly
> > now that you end up with a 15s delay on the first mount attempt when
> > it's not. This sort of use-case was the original idea behind the keys
> > API -- maybe it's time to figure out how to make that transition?
> > 
> > > > Finally, make sure that we set the correct service names for lockd,
> > > > statd and mountd in case we want to convert those to use rpcsec_gss at
> > > > some point in the future.
> > > > 
> > > > Fix the upcalls to use the right service names for gssd.  The old
> > > > version of the rpc.gssd upcall expects the service name to be either
> > > > "nfs" or "nfs4_cb", which it will then concatenate with the server name
> > > > to create a target name of nfs@<server> or nfs4_cb@<server>
> > > > 
> > > > Finally, make sure that we set the correct service names for lockd,
> > > > statd and mountd in case we want to convert those to use rpcsec_gss at
> > > > some point in the future.
> > > > 
> > > > Cc: Jan Stancek <jstancek@redhat.com>
> > > > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > ---
> > > >  fs/lockd/clntxdr.c          | 1 +
> > > >  fs/lockd/mon.c              | 1 +
> > > >  fs/nfs/client.c             | 1 +
> > > >  fs/nfs/mount_clnt.c         | 1 +
> > > >  fs/nfs/nfs3client.c         | 2 ++
> > > >  fs/nfsd/nfs4callback.c      | 1 +
> > > >  include/linux/sunrpc/clnt.h | 1 +
> > > >  net/sunrpc/rpc_pipe.c       | 3 ++-
> > > >  8 files changed, 10 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
> > > > index 9a55797..18d0c34 100644
> > > > --- a/fs/lockd/clntxdr.c
> > > > +++ b/fs/lockd/clntxdr.c
> > > > @@ -612,6 +612,7 @@ static struct rpc_stat		nlm_rpc_stats;
> > > >  
> > > >  const struct rpc_program	nlm_program = {
> > > >  		.name		= "lockd",
> > > > +		.service_name	= "nlockmgr",
> > > >  		.number		= NLM_PROGRAM,
> > > >  		.nrvers		= ARRAY_SIZE(nlm_versions),
> > > >  		.version	= nlm_versions,
> > > > diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> > > > index 1812f02..1ac10f4 100644
> > > > --- a/fs/lockd/mon.c
> > > > +++ b/fs/lockd/mon.c
> > > > @@ -606,6 +606,7 @@ static struct rpc_stat		nsm_stats;
> > > >  
> > > >  static const struct rpc_program nsm_program = {
> > > >  		.name		= "statd",
> > > > +		.service_name	= "status",
> > > >  		.number		= NSM_PROGRAM,
> > > >  		.nrvers		= ARRAY_SIZE(nsm_version),
> > > >  		.version	= nsm_version,
> > > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > > > index 340b1ef..9fb1050 100644
> > > > --- a/fs/nfs/client.c
> > > > +++ b/fs/nfs/client.c
> > > > @@ -72,6 +72,7 @@ static const struct rpc_version *nfs_version[5] = {
> > > >  
> > > >  const struct rpc_program nfs_program = {
> > > >  	.name			= "nfs",
> > > > +	.service_name		= "nfs",
> > > >  	.number			= NFS_PROGRAM,
> > > >  	.nrvers			= ARRAY_SIZE(nfs_version),
> > > >  	.version		= nfs_version,
> > > > diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> > > > index 99a4528..5f1a888 100644
> > > > --- a/fs/nfs/mount_clnt.c
> > > > +++ b/fs/nfs/mount_clnt.c
> > > > @@ -528,6 +528,7 @@ static struct rpc_stat mnt_stats;
> > > >  
> > > >  static const struct rpc_program mnt_program = {
> > > >  	.name		= "mount",
> > > > +	.service_name	= "mountd",
> > > >  	.number		= NFS_MNT_PROGRAM,
> > > >  	.nrvers		= ARRAY_SIZE(mnt_version),
> > > >  	.version	= mnt_version,
> > > > diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> > > > index b3fc65e..b61de6b 100644
> > > > --- a/fs/nfs/nfs3client.c
> > > > +++ b/fs/nfs/nfs3client.c
> > > > @@ -10,10 +10,12 @@ static const struct rpc_version *nfsacl_version[] = {
> > > >  
> > > >  const struct rpc_program nfsacl_program = {
> > > >  	.name			= "nfsacl",
> > > > +	.service_name		= "nfs",
> > > >  	.number			= NFS_ACL_PROGRAM,
> > > >  	.nrvers			= ARRAY_SIZE(nfsacl_version),
> > > >  	.version		= nfsacl_version,
> > > >  	.stats			= &nfsacl_rpcstat,
> > > > +	.pipe_dir_name		= "nfs",
> > > >  };
> > > >  
> > > >  /*
> > > > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > > > index 7f05cd1..2962890 100644
> > > > --- a/fs/nfsd/nfs4callback.c
> > > > +++ b/fs/nfsd/nfs4callback.c
> > > > @@ -596,6 +596,7 @@ static struct rpc_stat cb_stats = {
> > > >  #define NFS4_CALLBACK 0x40000000
> > > >  static const struct rpc_program cb_program = {
> > > >  	.name			= "nfs4_cb",
> > > > +	.service_name		= "nfs4_cb",
> > > >  	.number			= NFS4_CALLBACK,
> > > >  	.nrvers			= ARRAY_SIZE(nfs_cb_version),
> > > >  	.version		= nfs_cb_version,
> > > > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > > > index bfe11be..d902c55 100644
> > > > --- a/include/linux/sunrpc/clnt.h
> > > > +++ b/include/linux/sunrpc/clnt.h
> > > > @@ -70,6 +70,7 @@ struct rpc_clnt {
> > > >  #define RPC_MAXVERSION		4
> > > >  struct rpc_program {
> > > >  	const char *		name;		/* protocol name */
> > > > +	const char *		service_name;	/* protocol service name */
> > > >  	u32			number;		/* program number */
> > > >  	unsigned int		nrvers;		/* number of versions */
> > > >  	const struct rpc_version **	version;	/* version array */
> > > > diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> > > > index 406859c..83b196d 100644
> > > > --- a/net/sunrpc/rpc_pipe.c
> > > > +++ b/net/sunrpc/rpc_pipe.c
> > > > @@ -409,7 +409,8 @@ rpc_show_info(struct seq_file *m, void *v)
> > > >  	rcu_read_lock();
> > > >  	seq_printf(m, "RPC server: %s\n",
> > > >  			rcu_dereference(clnt->cl_xprt)->servername);
> > > > -	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
> > > > +	seq_printf(m, "service: %s (%d) version %d\n",
> > > > +			clnt->cl_program->service_name,
> > > >  			clnt->cl_prog, clnt->cl_vers);
> > > >  	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
> > > >  	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
> > > 
> > > 
> > 
> > 
> > -- 
> > Jeff Layton <jlayton@redhat.com>
