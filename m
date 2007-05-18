From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 3/15] knfsd: initialize RDMA transport in	sunrpc
Date: Fri, 18 May 2007 13:54:25 -0500
Message-ID: <1179514465.23385.147.camel@trinity.ogc.int>
References: <1179510296.23385.116.camel@trinity.ogc.int>
	<1179512587.6488.119.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7au-00005x-1I
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:54:28 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp7aw-0003oL-R0
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:54:31 -0700
In-Reply-To: <1179512587.6488.119.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 14:23 -0400, Trond Myklebust wrote:
> On Fri, 2007-05-18 at 12:44 -0500, Tom Tucker wrote:
> > Add calls to the svc_rdma initialization and cleanup routines to the
> > sunrpc module init logic.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  net/sunrpc/sunrpc_syms.c |   10 +++++++++-
> >  1 files changed, 9 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> > index 43ecf62..16a50c9 100644
> > --- a/net/sunrpc/sunrpc_syms.c
> > +++ b/net/sunrpc/sunrpc_syms.c
> > @@ -20,7 +20,9 @@ #include <linux/sunrpc/svcsock.h>
> >  #include <linux/sunrpc/auth.h>
> >  #include <linux/workqueue.h>
> >  #include <linux/sunrpc/rpc_pipe_fs.h>
> > -
> > +#ifdef CONFIG_NFSD_RDMA
> > +#include <linux/sunrpc/svc_rdma.h>
> > +#endif
> >  
> >  /* RPC scheduler */
> >  EXPORT_SYMBOL(rpc_execute);
> > @@ -158,6 +160,9 @@ #endif
> >  	cache_register(&ip_map_cache);
> >  	cache_register(&unix_gid_cache);
> >  	init_socket_xprt();
> > +#ifdef CONFIG_NFSD_RDMA
> > +	err = svc_rdma_init();
> > +#endif
> >  out:
> >  	return err;
> >  }
> > @@ -175,6 +180,9 @@ cleanup_sunrpc(void)
> >  #ifdef RPC_DEBUG
> >  	rpc_unregister_sysctl();
> >  #endif
> > +#ifdef CONFIG_NFSD_RDMA
> > +	svc_rdma_cleanup();
> > +#endif
> >  #ifdef CONFIG_PROC_FS
> >  	rpc_proc_exit();
> >  #endif
> 
> Hmm... You really want to reorder this patch. AFAICS you haven't defined
> either svc_rdma.h or svc_rdma_*().
> 
> Please also convert the above to avoid inlined #ifdef/#endif by defining
> inlined dummy versions of svc_rdma_cleanup/svc_rdma_init inside
> svc_rdma.h:
> 
> #ifdef CONFIG_NFSD_RDMA
> void svc_rdma_cleanup(void);
> #else
> static inline void svc_rdma_cleanup(void)
> {
> }
> #endif

Ok, I'll add this to the svc_rdma.h file. Thanks,

> 
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
