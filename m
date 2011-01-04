From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH_V7 04/12] NFS register and unregister back channel
 transport
Date: Tue, 4 Jan 2011 16:05:50 -0500
Message-ID: <20110104210549.GC7908@fieldses.org>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
 <1294173766-5573-2-git-send-email-andros@netapp.com>
 <1294173766-5573-3-git-send-email-andros@netapp.com>
 <1294173766-5573-4-git-send-email-andros@netapp.com>
 <1294173766-5573-5-git-send-email-andros@netapp.com>
 <1294174414.5896.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andros@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002Ab1ADVFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:05:52 -0500
In-Reply-To: <1294174414.5896.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 04, 2011 at 03:53:33PM -0500, Trond Myklebust wrote:
> On Tue, 2011-01-04 at 15:42 -0500, andros@netapp.com wrote: 
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfs/callback.c              |   20 +++++++++++++++++++-
> >  fs/nfs/callback.h              |    2 ++
> >  fs/nfs/inode.c                 |    4 ++++
> >  include/linux/sunrpc/svcsock.h |    3 ++-
> >  net/sunrpc/svcsock.c           |   13 +++++++++++++
> >  5 files changed, 40 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index 93a8b3b..241ab70 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -221,7 +221,17 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> >  	if (minorversion)
> >  		xprt->bc_serv = cb_info->serv;
> >  }
> > -#else
> > +
> > +void nfs_init_bc_xprt(void)
> > +{
> > +	svc_init_bc_xprt_sock();
> > +}
> > +
> > +void nfs_cleanup_bc_xprt(void)
> > +{
> > +	svc_cleanup_bc_xprt_sock();
> > +}
> > +#else /* CONFIG_NFS_V4_1 */
> >  static inline int nfs_minorversion_callback_svc_setup(u32 minorversion,
> >  		struct svc_serv *serv, struct rpc_xprt *xprt,
> >  		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
> > @@ -233,6 +243,14 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> >  		struct nfs_callback_data *cb_info)
> >  {
> >  }
> > +
> > +void nfs_init_bc_xprt(void)
> > +{
> > +}
> > +
> > +void nfs_cleanup_bc_xprt(void)
> > +{
> > +}
> >  #endif /* CONFIG_NFS_V4_1 */
> >  
> >  /*
> > diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> > index 85a7cfd..9206a2d 100644
> > --- a/fs/nfs/callback.h
> > +++ b/fs/nfs/callback.h
> > @@ -149,5 +149,7 @@ extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
> >  extern unsigned int nfs_callback_set_tcpport;
> >  extern unsigned short nfs_callback_tcpport;
> >  extern unsigned short nfs_callback_tcpport6;
> > +extern void nfs_init_bc_xprt(void);
> > +extern void nfs_cleanup_bc_xprt(void);
> >  
> >  #endif /* __LINUX_FS_NFS_CALLBACK_H */
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index e67e31c..28afea2 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -1571,6 +1571,9 @@ static int __init init_nfs_fs(void)
> >  #endif
> >  	if ((err = register_nfs_fs()) != 0)
> >  		goto out;
> > +
> > +	nfs_init_bc_xprt();
> > +
> 
> I'm not sure that I understand. Why would we want to do this in the NFS
> layer? Doesn't the above just belong in svc_init_xprt_sock()?

My bad, yes, I think you're right.

> > 	return 0;
> >  out:
> >  #ifdef CONFIG_PROC_FS
> > @@ -1612,6 +1615,7 @@ static void __exit exit_nfs_fs(void)
> >  #ifdef CONFIG_PROC_FS
> >  	rpc_proc_unregister("nfs");
> >  #endif
> > +	nfs_cleanup_bc_xprt();
> 
> Ditto.

Right, so svc_cleanup_xprt_sock for that one.

--b.
