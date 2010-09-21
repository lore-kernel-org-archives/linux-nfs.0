Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50832 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803Ab0IUMSR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 08:18:17 -0400
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4C985A88.1000902@parallels.com>
References: <4C90BADB.10700@parallels.com>
	 <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com>
	 <20100920180418.GN4580@fieldses.org>  <4C97B248.1030801@parallels.com>
	 <1285013116.2851.71.camel@heimdal.trondhjem.org>
	 <4C985A88.1000902@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Sep 2010 08:18:13 -0400
Message-ID: <1285071493.3105.55.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-21 at 11:11 +0400, Pavel Emelyanov wrote:
> > The client should be something like the following:
> > 
> >  1) Ensure sunrpc sockets are created using the correct net namespace
> 
> Ack
> 
> >  2) Convert rpc_pipefs to be per-net namespace.
> 
> Trond, I think this part should be done the other way.
> 
> You see, the rpc_pipefs is a filesystem already and we shouldn't
> make it bound to any task-driven context. What I was thinking about
> in that direction is make it mountable multiple times.
> 
> The central issue of this is - the way we say the rpc_get_mount() 
> which vfsmount we need. Userspace will just use the per-container (i.e.
> per-chroot) instance of it and the kernel users will work with the
> vfsmount obtained by the rpc_get_mount() call.
> 
> Now, how do I plan to solve the rpc_get_mount problem. Some time ago
> there was similar problem with the devpts filesystem - people making
> ptys work per-container tried to solve the same problem and they
> ended up (with Al's help) with a yet another devpts mount option which
> explicitly stated that a new instance should be created. How do you
> think if we do the same for rpc_pipefs (a newinstance mount option) and
> add yet another mount option for its only client (nfs) telling it where
> to look for the rpc mount for (e.g. rpcmount=/var/...) ?

As long as we have some mechanism to ensure that rpc.gssd from one net
namespace doesn't try to establish a kerberos security context on behalf
of a NFS mount that resides in a different net namespace.
My point is if the rpc.gssd resides in a different net namespace, then
we have no guarantee that the IP address we pass in the upcall even
points to the same server, so we must ensure that the namespaces match.

> >  3) Convert the nfs_client and superblock to be per-net namespace
> 
> Ack about the nfs_client, but as far as the superblock is
> concerned - I think we should tag only the nfs_server with
> net for the same reasons as in the item 2) above.

You should tag the nfs_server, and then make sure that nfs_compare_super
does not match something that is tagged with a different net namespace
than the current one. Otherwise, you can end up mounting the wrong NFS
server (for the same reason as above).

> >  4) Convert lockd's struct host to be per-net namespace

Cheers
  Trond
