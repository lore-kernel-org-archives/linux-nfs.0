Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab1IVLHW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 07:07:22 -0400
Date: Thu, 22 Sep 2011 07:06:48 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>,
        <skinsbursky@parallels.com>
Subject: Re: [PATCH] nfs: set vs_hidden on nfs4_callback_version4
Message-ID: <20110922070648.42c326e9@tlielax.poochiereds.net>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48055C@SACMVEXC2-PRD.hq.netapp.com>
References: <1316634942-5209-1-git-send-email-jlayton@redhat.com>
	<EBF75C5F-DEA6-4703-A787-FCE68C6B72E3@oracle.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48055C@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 21 Sep 2011 13:24:48 -0700
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: Chuck Lever [mailto:chuck.lever@oracle.com]
> > Sent: Wednesday, September 21, 2011 4:06 PM
> > To: Jeff Layton
> > Cc: Myklebust, Trond; linux-nfs@vger.kernel.org;
> skinsbursky@parallels.com
> > Subject: Re: [PATCH] nfs: set vs_hidden on nfs4_callback_version4
> > 
> > 
> > On Sep 21, 2011, at 3:55 PM, Jeff Layton wrote:
> > 
> > > This service should not be registered with or unregistered from
> rpcbind.
> > 
> > I've been watching the larger conversation.  One thing that
> registering does,
> > even if you don't want to advertise your service, is tell you if there
> is already
> > another service on that port.  Do we want to worry about possible port
> > collisions for listeners like the callback service?
> 
> We already have a module parameter for fixing the callback service so
> that we can avoid port collisions with known services. That said,
> normally we do not want to rely on the portmapper for detecting the
> existence of a service: that will in any case only detect RPC services
> and, as you point out below, is subject to stale entries.
> 

Doing so also seems like a potential DoS vector. Just register every
reserved port you can get your hands on and enjoy the show...

> > Do we want to ensure that any other service on that port is
> unregistered?
> > We would already discover a listener on our port when trying to create
> the
> > socket, but an old registration may persist even after that old
> service has
> > gone away.
> 
> If anyone tries to use the service which is advertised by the stale
> portmapper entry, then they will get a PROG_UNAVAIL error.
> 

We should also point out that other non-RPC based services in the
kernel do not deal with the portmapper at all. I don't see any harm
from unregistering these ports from the portmapper on service creation,
but I'm not sure it really provides much benefit.

In any case though, I didn't think the rpcbind protocol really gave you
the ability to unregister based on the just the port -- you have to do
it by program number. In order to do this, we'd need to poll for the
entire list of registered services and unregister any that have
matching ports. That sounds ugly to implement :-/

-- 
Jeff Layton <jlayton@redhat.com>
