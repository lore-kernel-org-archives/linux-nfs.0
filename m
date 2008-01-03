From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 12/38] svc: Add a generic transport svc_create_xprt
	function
Date: Thu, 3 Jan 2008 14:00:32 -0500
Message-ID: <20080103190032.GD15354@fieldses.org>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int> <20071129225603.15275.54556.stgit@dell3.ogc.int> <20071214230523.GI23121@fieldses.org> <1198261117.14237.47.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55767 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbYACTAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 14:00:33 -0500
In-Reply-To: <1198261117.14237.47.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2007 at 12:18:37PM -0600, Tom Tucker wrote:
> 
> On Fri, 2007-12-14 at 18:05 -0500, J. Bruce Fields wrote:
> > On Thu, Nov 29, 2007 at 04:56:03PM -0600, Tom Tucker wrote:
> > > --- a/net/sunrpc/svc_xprt.c
> > > +++ b/net/sunrpc/svc_xprt.c
> > > @@ -93,3 +93,40 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt)
> > >  	xprt->xpt_ops = xcl->xcl_ops;
> > >  }
> > >  EXPORT_SYMBOL_GPL(svc_xprt_init);
> > > +
> > > +int svc_create_xprt(struct svc_serv *serv, char *xprt_name, unsigned short port,
> > > +		    int flags)
> > > +{
> > > +	struct svc_xprt_class *xcl;
> > > +	int ret = -ENOENT;
> > > +	struct sockaddr_in sin = {
> > > +		.sin_family		= AF_INET,
> > > +		.sin_addr.s_addr	= INADDR_ANY,
> > > +		.sin_port		= htons(port),
> > > +	};
> > > +	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
> > > +	spin_lock(&svc_xprt_class_lock);
> > > +	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
> > > +		if (strcmp(xprt_name, xcl->xcl_name) == 0) {
> > > +			spin_unlock(&svc_xprt_class_lock);
> > > +			if (try_module_get(xcl->xcl_owner)) {
> > 
> > 
> > Hm.  I wonder if this is right.  Don't you need to do the try_module_get
> > while still under the svc_xprt_class_lock?
> > 
> 
> Hmm. This is an interesting question. I'm was assuming that the
> unregister call from the transport provider comes from the module_exit
> function.

Oh.  Are all module init/exit functions serialized?

The case I was wondering about was something like:

	task 1				task 2
	registering xcl named "foo"	unregistering different xcl also
					named "foo".

	Gets pointer to xcl which
	task 2 is unregistering,
	drops svc_xprt_class_lock.

					acquires svc_xprt_class_lock,
					frees the xcl.

	try_module_get(xcl->cl_owner)

But I don't understand the module code well enough to understand whether
that's possible.

> If it doesn't then you are correct you could have an active
> reference to a module that is not present in the transport class list. 

I think it's fine to assume that register will always be called from
init code and unregister from the module code, so if that solves the
problem, great.

--b.
