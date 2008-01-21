From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] svc: Modify svc_find_xprt to take a reference
Date: Mon, 21 Jan 2008 11:19:51 -0600
Message-ID: <1200935991.11003.39.camel@trinity.ogc.int>
References: <20080118165121.9787.8399.stgit@dell3.ogc.int>
	 <20080118201706.GJ15158@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:55715 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbYAURM1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 12:12:27 -0500
In-Reply-To: <20080118201706.GJ15158@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-18 at 15:17 -0500, J. Bruce Fields wrote:
> On Fri, Jan 18, 2008 at 10:51:21AM -0600, Tom Tucker wrote:
> > 
> > Modify svc_find_xprt to acquire a reference on a transport if it is found.
> > This fixes a race where the transport is found, but removed immediately
> > afterward leaving the caller with a pointer to a dead transport.
> 
> OK.  Applied (and folded in with "knfsd: Support adding transports by
> writing portlist file"); result included in
> 
> 	git://linux-nfs.org/~bfields/linux.git nfs-server-stable

Thanks Bruce.

> 
> --b.
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/lockd/svc.c        |   18 +++++++++++++-----
> >  fs/nfsd/nfsctl.c      |    1 +
> >  net/sunrpc/svc_xprt.c |    1 +
> >  3 files changed, 15 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index 470af01..0822646 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> > @@ -227,17 +227,25 @@ lockd(struct svc_rqst *rqstp)
> >  static int make_socks(struct svc_serv *serv, int proto)
> >  {
> >  	static int warned;
> > +	struct svc_xprt *xprt;
> >  	int err = 0;
> >  
> > -	if (proto == IPPROTO_UDP || nlm_udpport)
> > -		if (!svc_find_xprt(serv, "udp", 0, 0))
> > +	if (proto == IPPROTO_UDP || nlm_udpport) {
> > +		xprt = svc_find_xprt(serv, "udp", 0, 0);
> > +		if (!xprt)
> >  			err = svc_create_xprt(serv, "udp", nlm_udpport,
> >  					      SVC_SOCK_DEFAULTS);
> > -	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
> > -		if (!svc_find_xprt(serv, "tcp", 0, 0))
> > +		else
> > +			svc_xprt_put(xprt);
> > +	}
> > +	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
> > +		xprt = svc_find_xprt(serv, "tcp", 0, 0);
> > +		if (!xprt)
> >  			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
> >  					      SVC_SOCK_DEFAULTS);
> > -
> > +		else
> > +			svc_xprt_put(xprt);
> > +	}
> >  	if (err >= 0) {
> >  		warned = 0;
> >  		err = 0;
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 10c13ed..d22bc45 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -592,6 +592,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> >  						     AF_UNSPEC, port);
> >  				if (xprt) {
> >  					svc_close_xprt(xprt);
> > +					svc_xprt_put(xprt);
> >  					err = 0;
> >  				} else
> >  					err = -ENOTCONN;
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 5545c1e..c3fb367 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -1007,6 +1007,7 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
> >  		if (port && port != svc_xprt_local_port(xprt))
> >  			continue;
> >  		found = xprt;
> > +		svc_xprt_get(xprt);
> >  		break;
> >  	}
> >  	spin_unlock_bh(&serv->sv_lock);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

