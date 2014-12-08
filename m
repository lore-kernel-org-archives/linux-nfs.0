Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:35121 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257AbaLHUtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Dec 2014 15:49:23 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so3968598qab.12
        for <linux-nfs@vger.kernel.org>; Mon, 08 Dec 2014 12:49:22 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 8 Dec 2014 15:49:21 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 09/14] sunrpc: add basic support for workqueue-based
 services
Message-ID: <20141208154921.3e200c12@tlielax.poochiereds.net>
In-Reply-To: <20141208204709.GA19437@fieldses.org>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
	<1417544663-13299-10-git-send-email-jlayton@primarydata.com>
	<20141208204709.GA19437@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Dec 2014 15:47:09 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 02, 2014 at 01:24:18PM -0500, Jeff Layton wrote:
> > diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> > index fb78117b896c..08e01949bdc5 100644
> > --- a/net/sunrpc/Kconfig
> > +++ b/net/sunrpc/Kconfig
> > @@ -71,3 +71,13 @@ config SUNRPC_XPRT_RDMA_SERVER
> >  	  choose M here: the module will be called svcrdma.
> >  
> >  	  If unsure, say N.
> > +
> > +config SUNRPC_SVC_WORKQUEUE
> > +	bool "Support for workqueue-based SUNRPC services"
> > +	depends on SUNRPC
> > +	default	n
> > +	help
> > +	  Traditional SUNRPC services have required a dedicated thread
> > +	  to handle incoming requests. This option enables support for
> > +	  queueing incoming reqests to a workqueue instead, eliminating
> > +	  the need for a dedicated thread pool.
> 
> Minor point, but: If people don't want this, they can turn it off at
> runtime.  It's annoying to test all the possible combination of build
> options, and this doesn't seem likely to let people e.g. build a
> significantly smaller kernel, so I wouldn't bother.
> 
> --b.

Ok, fair enough. I added the config option since this was experimental,
but if we keep it runtime-switchable then I think you're probably right
and there's no need.

-- 
Jeff Layton <jlayton@primarydata.com>
