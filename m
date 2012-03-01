Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:40150 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965243Ab2CAW1e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:27:34 -0500
Subject: Re: [PATCH 07/15] SUNRPC: Add API to acquire source address
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120301220918.GA3778@umich.edu>
Date: Thu, 1 Mar 2012 17:27:27 -0500
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <51C34EC1-1EF2-4106-A2D9-3963C1C00A5C@oracle.com>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net> <20120301220114.2138.67690.stgit@degas.1015granger.net> <20120301220918.GA3778@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 1, 2012, at 5:09 PM, Jim Rees wrote:

> Chuck Lever wrote:
> 
>  NFSv4.0 clients must send endpoint information for their callback
>  service to NFSv4.0 servers during their first contact with a server.
>  Traditionally on Linux, user space provides the callback endpoint IP
>  address via the "clientaddr=" mount option.
> 
>  During an NFSv4 migration event, it is possible that an FSID may be
>  migrated to a destination server that is accessible via a different
>  source IP address than the source server was.  The client must update
>  callback endpoint information on the destination server so that it can
>  maintain leases and allow delegation.
> 
>  Without a new "clientaddr=" option from user space, however, the
>  kernel itself must construct an appropriate IP address for the
>  callback update.  Provide an API in the RPC client for upper layer
>  RPC consumers to acquire a source address for a remote.
> 
>  The mechanism used by the mount.nfs command is copied: set up a
>  connected UDP socket to the designated remote, then scrape the source
>  address off the socket.  We are careful to select the correct network
>  namespace when setting up the temporary UDP socket.
> 
> That seems like a lot of work.  On OpenBSD it's a one-liner, a call into the
> routing system to get the device and source address that would be used to
> talk to a given destination.

The goal here is to emulate exactly what is done in user space so that the result is the same whether the address is obtained in the kernel or by the mount.nfs command.

> Is there no equivalent in linux?

No idea.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




