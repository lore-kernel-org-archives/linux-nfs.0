Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754805Ab2GYP5K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 11:57:10 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120725155347.24392.44505.stgit@warthog.procyon.org.uk>
References: <20120725155347.24392.44505.stgit@warthog.procyon.org.uk> <20120725155336.24392.25186.stgit@warthog.procyon.org.uk>
To: Trond.Myklebust@netapp.com
Cc: dhowells@redhat.com, bjschuma@netapp.com, linux-nfs@vger.kernel.org,
        steved@redhat.com, jlayton@redhat.com
Subject: Re: [PATCH 2/2] NFS: Combine the idmapper key types
Date: Wed, 25 Jul 2012 16:57:05 +0100
Message-ID: <24518.1343231825@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,

David Howells <dhowells@redhat.com> wrote:

> The NFS idmapper has two key types (normal and legacy) but should only use one
> if it can - otherwise it risks having twice as many keys as it would otherwise
> need.
> 
> Get rid of the legacy key type and have the normal key type have a
> .request_key() op.  The choice of which instantiation method is then made by
> the upcaller, in order:
> 
>  (1) If there's no auxdata, the normal method is called, invoking
>      /sbin/request-key.
> 
>  (2) If there's something attached to the idmapper pipe (rpc.idmapd) then use
>      that.
> 
>  (3) Fall back to (1).
> 
> Note that this does change the prioritisation of normal vs legacy if both are
> available.

I'm not sure whether this will be a problem, so it needs careful
consideration.

David
