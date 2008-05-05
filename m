From: Steve Dickson <SteveD@redhat.com>
Subject: Re: EACCES in mount.nfs
Date: Mon, 05 May 2008 08:24:02 -0400
Message-ID: <481EFC62.9030808@RedHat.com>
References: <183E9EC8-78F5-4352-BB01-84F9CE4F72FE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754979AbYEEM3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 08:29:03 -0400
In-Reply-To: <183E9EC8-78F5-4352-BB01-84F9CE4F72FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delayed response... I spent most of last week
off line due to Red Hat moving to a new building...  fun, fun, fun! :-\

Chuck Lever wrote:
> Hi Steve-
> 
> There is an important case in mount.nfs where EACCES is temporary:  The
> kernel's rpcbind client returns EACCES if the remote rpcbind server
> replies that the requested service is not registered.
I guess I see the reasoning behind this... a server could be coming
up so the mount should hang around waiting for that...

> 
> It would be easy enough for the kernel's mount client to remap that
> error code into something unique for the mount system call.
I would think ENOENT would be a better mapping for RPC_PROG_UNAVAIL.

But that still leaves the possible problem of the mount not waiting 
around for servers to come up... Or do we even have to worry about 
mounts failing because a server is not up yet?  I'm beginning to
think not...


steved.

