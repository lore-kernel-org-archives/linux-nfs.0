Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44512 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2392441AbeHPTjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 15:39:01 -0400
Message-ID: <db81635e277b32df7b0e708241de08d06d0d4c9a.camel@redhat.com>
Subject: Re: [PATCH v2 1/4] sunrpc: Enable the kernel to specify the
 hostname part of service principals
From: Simo Sorce <simo@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 16 Aug 2018 12:39:21 -0400
In-Reply-To: <3e9c0dd18719fdc37a00aa5f5e9cddc8010d24e5.camel@hammerspace.com>
References: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
         <20180816160554.2230.58754.stgit@klimt.1015granger.net>
         <3e9c0dd18719fdc37a00aa5f5e9cddc8010d24e5.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-08-16 at 16:27 +0000, Trond Myklebust wrote:
> On Thu, 2018-08-16 at 12:05 -0400, Chuck Lever wrote:
> > A multi-homed NFS server may have more than one "nfs" key in its
> > keytab. Enable the kernel to pick the key it wants as a machine
> > credential when establishing a GSS context.
> > 
> > This is useful for GSS-protected NFSv4.0 callbacks, which are
> > required by RFC 7530 S3.3.3 to use the same principal as the service
> > principal the client used when establishing its lease.
> > 
> > A complementary modification to rpc.gssd is required to fully enable
> > this feature.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c |   20 +++++++++++++++++---
> >  1 file changed, 17 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c
> > b/net/sunrpc/auth_gss/auth_gss.c
> > index be8f103..1943e11 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -284,7 +284,12 @@ struct gss_auth {
> >  	return p;
> >  }
> >  
> > -#define UPCALL_BUF_LEN 128
> > +/* XXX: Need some documentation about why UPCALL_BUF_LEN is so
> > small.
> > + *	Is user space expecting no more than UPCALL_BUF_LEN bytes?
> > + *	Note that there are now _two_ NI_MAXHOST sized data items
> > + *	being passed in this string.
> > + */
> > +#define UPCALL_BUF_LEN	256
> >  
> 
> Why? The services are currently "nfs" or "nfsd". Hostnames are normally
> < 64 characters.

For Kerberos hostnames are fully qualified DNS names, so easily longer
than 64 bytes.

> >  struct gss_upcall_msg {
> >  	refcount_t count;
> > @@ -462,8 +467,17 @@ static int gss_encode_v1_msg(struct
> > gss_upcall_msg *gss_msg,
> >  		p += len;
> >  		gss_msg->msg.len += len;
> >  	}
> > -	if (service_name != NULL) {
> > -		len = scnprintf(p, buflen, "service=%s ",
> > service_name);
> > +	if (service_name) {
> > +		char *c = strchr(service_name, '@');
> > +
> > +		if (!c)
> > +			len = scnprintf(p, buflen, "service=%s ",
> > +					service_name);
> > +		else
> > +			len = scnprintf(p, buflen,
> > +					"service=%.*s srchost=%s ",
> > +					(int)(c - service_name),
> > +					service_name, c + 1);
> >  		buflen -= len;
> >  		p += len;
> >  		gss_msg->msg.len += len;
> 
> Isn't this just duplicating the functionality of the 'target' argument?

No, but I'll let Chuck re-explain.

Chuck, people are often confused about this, perhaps we need a
clarifying comment here to avoid some "optimization" to the code to
happen later.

HTH,
Simo.

> 
> -- 
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
> 
> 
