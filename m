Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45786 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244Ab1IUUZG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 16:25:06 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] nfs: set vs_hidden on nfs4_callback_version4
Date: Wed, 21 Sep 2011 13:24:48 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B48055C@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <EBF75C5F-DEA6-4703-A787-FCE68C6B72E3@oracle.com>
References: <1316634942-5209-1-git-send-email-jlayton@redhat.com> <EBF75C5F-DEA6-4703-A787-FCE68C6B72E3@oracle.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@redhat.com>
Cc: <linux-nfs@vger.kernel.org>, <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Wednesday, September 21, 2011 4:06 PM
> To: Jeff Layton
> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org;
skinsbursky@parallels.com
> Subject: Re: [PATCH] nfs: set vs_hidden on nfs4_callback_version4
> 
> 
> On Sep 21, 2011, at 3:55 PM, Jeff Layton wrote:
> 
> > This service should not be registered with or unregistered from
rpcbind.
> 
> I've been watching the larger conversation.  One thing that
registering does,
> even if you don't want to advertise your service, is tell you if there
is already
> another service on that port.  Do we want to worry about possible port
> collisions for listeners like the callback service?

We already have a module parameter for fixing the callback service so
that we can avoid port collisions with known services. That said,
normally we do not want to rely on the portmapper for detecting the
existence of a service: that will in any case only detect RPC services
and, as you point out below, is subject to stale entries.

> Do we want to ensure that any other service on that port is
unregistered?
> We would already discover a listener on our port when trying to create
the
> socket, but an old registration may persist even after that old
service has
> gone away.

If anyone tries to use the service which is advertised by the stale
portmapper entry, then they will get a PROG_UNAVAIL error.

Cheers
  Trond
