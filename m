From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 9/15] knfsd: add RDMA debug class to	rpc_debug bitfield
Date: Fri, 18 May 2007 13:57:46 -0500
Message-ID: <1179514666.23385.152.camel@trinity.ogc.int>
References: <1179510345.23385.122.camel@trinity.ogc.int>
	<464DF5F9.2090205@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7e8-0000Ok-UA
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:57:48 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp7eB-0004jw-Ld
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:57:51 -0700
In-Reply-To: <464DF5F9.2090205@oracle.com>
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

On Fri, 2007-05-18 at 14:52 -0400, Chuck Lever wrote:
> Hi Tom-
> 
> On the client side, I added a generic debug flag for transports, not a 
> specific flag for sockets.  Would you consider doing the same here?

Right. That's what I should do here too.

Thanks,
> 
> Tom Tucker wrote:
> > Add a bit to the rpc_debug bit field for RDMA transport
> > debug messages and sysctl definitions for configuration
> > and statistics files in /proc/sys/sunrpc/svc_rdma.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  include/linux/sunrpc/debug.h |   15 +++++++++++++++
> >  1 files changed, 15 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
> > index fc3a5dd..9bf7381 100644
> > --- a/include/linux/sunrpc/debug.h
> > +++ b/include/linux/sunrpc/debug.h
> > @@ -24,6 +24,7 @@ #define RPCDBG_SVCSOCK		0x0100
> >  #define RPCDBG_SVCDSP		0x0200
> >  #define RPCDBG_MISC		0x0400
> >  #define RPCDBG_CACHE		0x0800
> > +#define RPCDBG_RDMA		0x1000
> >  #define RPCDBG_ALL		0x7fff
> >  
> >  #ifdef __KERNEL__
> > @@ -93,6 +94,20 @@ enum {
> >  	CTL_RDMA_MAXINLINEWRITE,
> >  	CTL_RDMA_WRITEPADDING,
> >  	CTL_RDMA_MEMREG,
> > +	CTL_SVCRDMA,
> > +	CTL_RDMA_MAX_REQUESTS,
> > +	CTL_RDMA_MAX_REQ_SIZE,
> > +	CTL_RDMA_ORD,
> > +	CTL_RDMA_READ_THROTTLE,
> > +	CTL_RDMA_STAT_RECV,
> > +	CTL_RDMA_STAT_READ,
> > +	CTL_RDMA_STAT_WRITE,
> > +	CTL_RDMA_STAT_SQ_STARVE,
> > +	CTL_RDMA_STAT_RQ_STARVE,
> > +	CTL_RDMA_STAT_RQ_POLL,
> > +	CTL_RDMA_STAT_RQ_PROD,
> > +	CTL_RDMA_STAT_SQ_POLL,
> > +	CTL_RDMA_STAT_SQ_PROD
> >  };
> >  
> >  #endif /* _LINUX_SUNRPC_DEBUG_H_ */
> > 
> > 
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by DB2 Express
> > Download DB2 Express C - the FREE version of DB2 express and take
> > control of your XML. No limits. Just data. Click to get it now.
> > http://sourceforge.net/powerbar/db2/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
