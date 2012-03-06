Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031065Ab2CFUsK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 15:48:10 -0500
Date: Tue, 6 Mar 2012 15:48:02 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v9 3/6] nfsd: add a per-net-namespace struct for nfsd
Message-ID: <20120306154802.00e76225@tlielax.poochiereds.net>
In-Reply-To: <20120306133124.5dbef60c@tlielax.poochiereds.net>
References: <1331047733-1641-1-git-send-email-jlayton@redhat.com>
	<1331047733-1641-4-git-send-email-jlayton@redhat.com>
	<4F564CCD.9040708@parallels.com>
	<20120306133124.5dbef60c@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Mar 2012 13:31:24 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 06 Mar 2012 21:43:41 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
> 
> > 06.03.2012 19:28, Jeff Layton пишет:
> > > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > > index 64c24af..141197e 100644
> > > --- a/fs/nfsd/nfsctl.c
> > > +++ b/fs/nfsd/nfsctl.c
> > > @@ -19,6 +19,7 @@
> > >   #include "nfsd.h"
> > >   #include "cache.h"
> > >   #include "fault_inject.h"
> > > +#include "netns.h"
> > >
> > >   /*
> > >    *	We have a single directory with several nodes in it.
> > > @@ -1124,14 +1125,23 @@ static int create_proc_exports_entry(void)
> > >   }
> > >   #endif
> > >
> > > +int nfsd_net_id;
> > > +static struct pernet_operations nfsd_net_ops = {
> > > +	.id   =&nfsd_net_id,
> > > +	.size = sizeof(struct nfsd_net),
> > > +};
> > > +
> > >   static int __init init_nfsd(void)
> > >   {
> > >   	int retval;
> > >   	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
> > >
> > > +	retval = register_pernet_subsys(&nfsd_net_ops);
> > 
> > Hi, Jeff.
> > You've created per-net structure and operations and that's cool.
> > But why don't you move nfsd client tracking control into per-net operations?
> > I.e. add init-exit callbacks in struct pernet_operations and call 
> > nfsd4_client_tracking_init() and nfsd4_client_tracking_exit() respectively in there?
> > And since we don't support any other networks namesapce except init_net, then 
> > just skip all others in these callbacks.
> > 
> 
> Well...the way I had envisioned it is that you'd create a new net
> namespace container and would then start up nfsd within that container.
> 
> Just because we're spawning a new namespace doesn't mean that we'll
> necessarily want to serve nfs from it, right? If we do it this way,
> then we don't end up allocating resources for containers that aren't
> going to use it.
> 
> ...or do I not understand the "vision" of how all of this is going to
> eventually work?
> 

To carry this thought a little further...

The pernet operations get registered whenever the module is plugged in.
The reason for doing it the way I did it here is that we don't need or
really want to do the client_tracking_init until we start up nfsd.

This is particularly the case with the legacy client tracker, which
slurps in the contents of v4recoverydir when it initializes. We don't
really want to do that at module plugin, I don't think.

-- 
Jeff Layton <jlayton@redhat.com>
