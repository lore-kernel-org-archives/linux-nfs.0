From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 37/38] knfsd: Support adding transports by writing
	portlist file
Date: Fri, 21 Dec 2007 11:52:30 -0600
Message-ID: <1198259550.14237.33.camel@trinity.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	 <20071211233316.15718.85089.stgit@dell3.ogc.int>
	 <20071214235109.GO23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48412 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753278AbXLURq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2007 12:46:59 -0500
In-Reply-To: <20071214235109.GO23121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-12-14 at 18:51 -0500, J. Bruce Fields wrote:
> On Tue, Dec 11, 2007 at 05:33:16PM -0600, Tom Tucker wrote:
> > 
> > Update the write handler for the portlist file to allow creating new
> > listening endpoints on a transport. The general form of the string is:
> > 
> > <transport_name><space><port number>
> > 
> > For example:
> > 
> > echo "tcp 2049" > /proc/fs/nfsd/portlist
> > 
> > This is intended to support the creation of a listening endpoint for
> > RDMA transports without adding #ifdef code to the nfssvc.c file.
> > 
> > Transports can also be removed as follows:
> > 
> > '-'<transport_name><space><port number>
> > 
> > For example:
> > 
> > echo "-tcp 2049" > /proc/fs/nfsd/portlist
> > 
> > Attempting to add a listener with an invalid transport string results
> > in EPROTONOSUPPORT and a perror string of "Protocol not supported". 
> > 
> > Attempting to remove an non-existent listener (.e.g. bad proto or port)
> > results in ENOTCONN and a perror string of 
> > "Transport endpoint is not connected"
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/nfsd/nfsctl.c      |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
> >  net/sunrpc/svc_xprt.c |    1 +
> >  2 files changed, 52 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 77dc989..5b9ed0e 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -540,7 +540,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> >  		}
> >  		return err < 0 ? err : 0;
> >  	}
> > -	if (buf[0] == '-') {
> > +	if (buf[0] == '-' && isdigit(buf[1])) {
> >  		char *toclose = kstrdup(buf+1, GFP_KERNEL);
> >  		int len = 0;
> >  		if (!toclose)
> > @@ -554,6 +554,56 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> >  		kfree(toclose);
> >  		return len;
> >  	}
> > +	/*
> > +	 * Add a transport listener by writing it's transport name
> > +	 */
> > +	if (isalpha(buf[0])) {
> > +		int err;
> > +		char transport[16];
> > +		int port;
> > +		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
> > +			err = nfsd_create_serv();
> > +			if (!err) {
> > +				if (svc_find_xprt(nfsd_serv, transport,
> > +						  AF_UNSPEC, port))
> > +					return -EADDRINUSE;
> 
> Shouldn't svc_create_xprt do this check for us itself?  (And if it
> doesn't, isn't there some minor race between two writers both checking,
> finding nothing, and then both svc_create_xprt()ing?)
> 

You're right. fixed.

> > +
> > +				err = svc_create_xprt(nfsd_serv,
> > +						      transport, port,
> > +						      SVC_SOCK_ANONYMOUS);
> > +				if (err == -ENOENT)
> > +					/* Give a reasonable perror msg for
> > +					 * bad transport string */
> > +					err = -EPROTONOSUPPORT;
> > +			}
> > +			return err < 0 ? err : 0;
> > +		}
> > +	}
> > +	/*
> > +	 * Remove a transport by writing it's transport name and port number
> > +	 */
> > +	if (buf[0] == '-' && isalpha(buf[1])) {
> > +		struct svc_xprt *xprt;
> > +		int err = -EINVAL;
> > +		char transport[16];
> > +		int port;
> > +		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
> > +			if (port == 0)
> > +				return -EINVAL;
> > +			lock_kernel();
> > +			if (nfsd_serv) {
> > +				xprt = svc_find_xprt(nfsd_serv, transport,
> > +						     AF_UNSPEC, port);
> > +				if (xprt) {
> > +					svc_close_xprt(xprt);
> > +					err = 0;
> 
> Hm, also: I'd have thought that svc_find_xprt should be incrementing the
> reference count on the returned xprt, if we're expecting the caller to
> do anything with it other than check it against NULL.
> 
> --b.
> 
> 
> > +				} else
> > +					err = -ENOTCONN;
> > +			}
> > +			unlock_kernel();
> > +			return err < 0 ? err : 0;
> > +		}
> > +	}
> >  	return -EINVAL;
> >  }
> >  
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 9815c6f..6708aa2 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -827,6 +827,7 @@ void svc_close_xprt(struct svc_xprt *xprt)
> >  	clear_bit(XPT_BUSY, &xprt->xpt_flags);
> >  	svc_xprt_put(xprt);
> >  }
> > +EXPORT_SYMBOL_GPL(svc_close_xprt);
> >  
> >  void svc_close_all(struct list_head *xprt_list)
> >  {
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

