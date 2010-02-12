From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC] [PATCH 0/4] Protocol family negotiation in mount.nfs
Date: Fri, 12 Feb 2010 13:46:40 -0500
Message-ID: <4B75A210.7040701@RedHat.com>
References: <20100122210221.10598.84522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960Ab0BLSqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 13:46:44 -0500
In-Reply-To: <20100122210221.10598.84522.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/22/2010 04:06 PM, Chuck Lever wrote:
> Hi Jeff-
> 
> For the record, here are patches that add support to mount.nfs for
> negotiating the protocol family correctly with servers that have both
> IPv4 and IPv6 addresses.
> 
> I've done some basic testing here against Solaris NFS servers, Linux
> with rpcbind (Fedora 12), and Linux with portmap (Ubuntu 9.10).
> 
> ---
> 
> Chuck Lever (4):
>       text-based mount: Support protocol family negotiation
>       text-based mount: Set addr= option in nfs_try_mount_foo()
>       text-based mount: Replace nfs_lookup() with getaddrinfo(3)
>       text-based mount: Retry when server can't be reached
> 
> 
>  utils/mount/nfs.man   |    6 ++
>  utils/mount/stropts.c |  120 ++++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 107 insertions(+), 19 deletions(-)
> 
All four patches tested and committed...

steved.
