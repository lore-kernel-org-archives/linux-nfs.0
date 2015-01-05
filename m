Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:42983 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbbAEXXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2015 18:23:19 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so29452845pac.25
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 15:23:18 -0800 (PST)
Date: Mon, 5 Jan 2015 15:23:14 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 08/49] nfsv3: introduce nfs3_set_ds_client
Message-ID: <20150105232314.GC3268@kitty.kitty>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
 <1419405208-25975-9-git-send-email-loghyr@primarydata.com>
 <54AAB933.5010501@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54AAB933.5010501@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 05, 2015 at 11:17:55AM -0500, Anna Schumaker wrote:
> Hey,
> 
> On 12/24/2014 02:12 AM, Tom Haynes wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> > 
> > The flexfiles layout wants to create DS connection over NFSv3.
> > Add nfs3_set_ds_client to allow that to happen.
> > 
> > Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> > Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> > ---
> >  fs/nfs/internal.h   |  4 ++++
> >  fs/nfs/nfs3_fs.h    |  3 ++-
> >  fs/nfs/nfs3client.c | 34 ++++++++++++++++++++++++++++++++++
> >  fs/nfs/nfs3super.c  |  2 +-
> >  4 files changed, 41 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 7d7c36f..7332ba1 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -193,6 +193,10 @@ extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
> >  					     rpc_authflavor_t au_flavor);
> >  extern struct rpc_clnt *nfs4_find_or_create_ds_client(struct nfs_client *,
> >  						struct inode *);
> > +extern struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
> > +			const struct sockaddr *ds_addr, int ds_addrlen,
> > +			int ds_proto, unsigned int ds_timeo,
> > +			unsigned int ds_retrans, rpc_authflavor_t au_flavor);
> >  #ifdef CONFIG_PROC_FS
> >  extern int __init nfs_fs_proc_init(void);
> >  extern void nfs_fs_proc_exit(void);
> > diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
> > index 333ae40..fc9cd85 100644
> > --- a/fs/nfs/nfs3_fs.h
> > +++ b/fs/nfs/nfs3_fs.h
> > @@ -29,6 +29,7 @@ static inline int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
> >  struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
> >  struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
> >  				     struct nfs_fattr *, rpc_authflavor_t);
> > -
> > +/* nfs3super.c */
> > +extern struct nfs_subversion nfs_v3;
> 
> nit:   Can we keep the blank line between nfs3client.c and nfs3super.c sections?

Yes, I will get it back in the next revision.

> 
> Thanks,
> Anna
> 
> >  
> >  #endif /* __LINUX_FS_NFS_NFS3_FS_H */
> > diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> > index 8c1b437..52e2344 100644
> > --- a/fs/nfs/nfs3client.c
> > +++ b/fs/nfs/nfs3client.c
> > @@ -64,3 +64,37 @@ struct nfs_server *nfs3_clone_server(struct nfs_server *source,
> >  		nfs_init_server_aclclient(server);
> >  	return server;
> >  }
> > +
> > +/*
> > + * Set up a pNFS Data Server client over NFSv3.
> > + *
> > + * Return any existing nfs_client that matches server address,port,version
> > + * and minorversion.
> > + *
> > + * For a new nfs_client, use a soft mount (default), a low retrans and a
> > + * low timeout interval so that if a connection is lost, we retry through
> > + * the MDS.
> > + */
> > +struct nfs_client *nfs3_set_ds_client(struct nfs_client *mds_clp,
> > +		const struct sockaddr *ds_addr, int ds_addrlen,
> > +		int ds_proto, unsigned int ds_timeo, unsigned int ds_retrans,
> > +		rpc_authflavor_t au_flavor)
> > +{
> > +	struct nfs_client_initdata cl_init = {
> > +		.addr = ds_addr,
> > +		.addrlen = ds_addrlen,
> > +		.nfs_mod = &nfs_v3,
> > +		.proto = ds_proto,
> > +		.net = mds_clp->cl_net,
> > +	};
> > +	struct rpc_timeout ds_timeout;
> > +	struct nfs_client *clp;
> > +
> > +	/* Use the MDS nfs_client cl_ipaddr. */
> > +	nfs_init_timeout_values(&ds_timeout, ds_proto, ds_timeo, ds_retrans);
> > +	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
> > +			     au_flavor);
> > +
> > +	return clp;
> > +}
> > +EXPORT_SYMBOL_GPL(nfs3_set_ds_client);
> > diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
> > index 6af29c2..5c4394e 100644
> > --- a/fs/nfs/nfs3super.c
> > +++ b/fs/nfs/nfs3super.c
> > @@ -7,7 +7,7 @@
> >  #include "nfs3_fs.h"
> >  #include "nfs.h"
> >  
> > -static struct nfs_subversion nfs_v3 = {
> > +struct nfs_subversion nfs_v3 = {
> >  	.owner = THIS_MODULE,
> >  	.nfs_fs   = &nfs_fs_type,
> >  	.rpc_vers = &nfs_version3,
> > 
> 
