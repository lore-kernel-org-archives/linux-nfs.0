From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 38/38] svc: Add svc_xprt_names service to replace
	svc_sock_names
Date: Fri, 21 Dec 2007 11:51:47 -0600
Message-ID: <1198259507.14237.31.camel@trinity.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
	 <20071211233318.15718.11614.stgit@dell3.ogc.int>
	 <20071215000328.GP23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48406 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751402AbXLURqQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2007 12:46:16 -0500
In-Reply-To: <20071215000328.GP23121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-12-14 at 19:03 -0500, J. Bruce Fields wrote:
> On Tue, Dec 11, 2007 at 05:33:18PM -0600, Tom Tucker wrote:
> > 
> > Create a transport independent version of the svc_sock_names function.
> > 
> > The toclose capability of the svc_sock_names service can be implemented
> > using the svc_xprt_find and svc_xprt_close services.
> 
> Should we delete the toclose checks from svc_sock_names(), then, under
> the assumption it's always called with toclose non-NULL now?
> 
> And why can't we just completely replace svc_sock_names() at this point?
> 

IMO we could, but there is currently a difference in behavior between
svc_sock_names and svc_find_xprt/close. svc_find_xprt doesn't care what
the IP address is, it only compares transport name, address family and
port. 

Presently in NFS, we only ever listen on zero, but you can destroy an
endpoint on a particular interface (IP address). Can anyone shed some
light on why this is? 

> --b.
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/nfsd/nfsctl.c                |    2 +-
> >  include/linux/sunrpc/svc_xprt.h |    1 +
> >  net/sunrpc/svc_xprt.c           |   35 +++++++++++++++++++++++++++++++++++
> >  3 files changed, 37 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 5b9ed0e..86d084e 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -503,7 +503,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
> >  		int len = 0;
> >  		lock_kernel();
> >  		if (nfsd_serv)
> > -			len = svc_sock_names(buf, nfsd_serv, NULL);
> > +			len = svc_xprt_names(nfsd_serv, buf, 0);
> >  		unlock_kernel();
> >  		return len;
> >  	}
> > diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> > index 840b5c4..ed9791a 100644
> > --- a/include/linux/sunrpc/svc_xprt.h
> > +++ b/include/linux/sunrpc/svc_xprt.h
> > @@ -81,6 +81,7 @@ void	svc_delete_xprt(struct svc_xprt *xprt);
> >  int	svc_port_is_privileged(struct sockaddr *sin);
> >  int	svc_print_xprts(char *buf, int maxlen);
> >  struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, int, int);
> > +int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
> >  static inline void svc_xprt_get(struct svc_xprt *xprt)
> >  {
> >  	kref_get(&xprt->xpt_ref);
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index 6708aa2..2e3a672 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -998,3 +998,38 @@ struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
> >  	return found;
> >  }
> >  EXPORT_SYMBOL_GPL(svc_find_xprt);
> > +
> > +/*
> > + * Format a buffer with a list of the active transports. A zero for
> > + * the buflen parameter disables target buffer overflow checking.
> > + */
> > +int svc_xprt_names(struct svc_serv *serv, char *buf, int buflen)
> > +{
> > +	struct svc_xprt *xprt;
> > +	char xprt_str[64];
> > +	int totlen = 0;
> > +	int len;
> > +
> > +	/* Sanity check args */
> > +	if (!serv)
> > +		return 0;
> > +
> > +	spin_lock_bh(&serv->sv_lock);
> > +	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
> > +		len = snprintf(xprt_str, sizeof(xprt_str),
> > +			       "%s %d\n", xprt->xpt_class->xcl_name,
> > +			       svc_xprt_local_port(xprt));
> > +		/* If the string was truncated, replace with error string */
> > +		if (len >= sizeof(xprt_str))
> > +			strcpy(xprt_str, "name-too-long\n");
> > +		/* Don't overflow buffer */
> > +		len = strlen(xprt_str);
> > +		if (buflen && (len + totlen >= buflen))
> > +			break;
> > +		strcpy(buf+totlen, xprt_str);
> > +		totlen += len;
> > +	}
> > +	spin_unlock_bh(&serv->sv_lock);
> > +	return totlen;
> > +}
> > +EXPORT_SYMBOL_GPL(svc_xprt_names);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

