Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab0LXRnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Dec 2010 12:43:19 -0500
Date: Fri, 24 Dec 2010 12:43:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH_V5 03/11] SUNRPC new transport for the NFSv4.1 shared
 back channel
Message-ID: <20101224174307.GD2889@fieldses.org>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
 <1292879088-7821-3-git-send-email-andros@netapp.com>
 <1292879088-7821-4-git-send-email-andros@netapp.com>
 <20101222222414.GD13243@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101222222414.GD13243@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 22, 2010 at 05:24:14PM -0500, bfields wrote:
> On Mon, Dec 20, 2010 at 04:04:40PM -0500, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Move the current sock create and destroy routines into the new transport ops.
> > Back channel socket will be destroyed by the svc_closs_all call in svc_destroy.
> 
> Also note you're adding UDP check?

Oh, and a minor nit there:

> > +		printk(KERN_WARNING "svc: only and TCP sockets"
					       ^^^

Just fix that message.  Other than that, everything looks OK to me.

--b.

> > +			" supported on shared back channel\n");
> > +		return ERR_PTR(-EINVAL);
> > +	}
> >  
> > -	dprintk("svc: %s\n", __func__);
> >  	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
> >  	if (!svsk)
> > -		goto out;
> > +		return ERR_PTR(-ENOMEM);
> >  
> >  	xprt = &svsk->sk_xprt;
> > -	if (prot == IPPROTO_TCP)
> > -		svc_xprt_init(&svc_tcp_class, xprt, serv);
> > -	else if (prot == IPPROTO_UDP)
> > -		svc_xprt_init(&svc_udp_class, xprt, serv);
> > -	else
> > -		BUG();
> > -out:
> > -	dprintk("svc: %s return %p\n", __func__, xprt);
> > +	svc_xprt_init(&svc_tcp_bc_class, xprt, serv);
> > +
> > +	serv->bc_xprt = xprt;
> > +
> >  	return xprt;
> >  }
> > -EXPORT_SYMBOL_GPL(svc_sock_create);
> >  
> >  /*
> > - * Destroy a svc_sock.
> > + * Free a back channel svc_sock.
> >   */
> > -void svc_sock_destroy(struct svc_xprt *xprt)
> > +static void svc_bc_sock_free(struct svc_xprt *xprt)
> >  {
> >  	if (xprt)
> >  		kfree(container_of(xprt, struct svc_sock, sk_xprt));
> >  }
> > -EXPORT_SYMBOL_GPL(svc_sock_destroy);
> > +#endif /* CONFIG_NFS_V4_1 */
> > -- 
> > 1.6.6
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
