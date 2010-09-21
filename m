Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31312 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317Ab0IUHLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 03:11:37 -0400
Message-ID: <4C985A88.1000902@parallels.com>
Date: Tue, 21 Sep 2010 11:11:04 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
References: <4C90BADB.10700@parallels.com>	 <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com>	 <20100920180418.GN4580@fieldses.org>  <4C97B248.1030801@parallels.com> <1285013116.2851.71.camel@heimdal.trondhjem.org>
In-Reply-To: <1285013116.2851.71.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> The client should be something like the following:
> 
>  1) Ensure sunrpc sockets are created using the correct net namespace

Ack

>  2) Convert rpc_pipefs to be per-net namespace.

Trond, I think this part should be done the other way.

You see, the rpc_pipefs is a filesystem already and we shouldn't
make it bound to any task-driven context. What I was thinking about
in that direction is make it mountable multiple times.

The central issue of this is - the way we say the rpc_get_mount() 
which vfsmount we need. Userspace will just use the per-container (i.e.
per-chroot) instance of it and the kernel users will work with the
vfsmount obtained by the rpc_get_mount() call.

Now, how do I plan to solve the rpc_get_mount problem. Some time ago
there was similar problem with the devpts filesystem - people making
ptys work per-container tried to solve the same problem and they
ended up (with Al's help) with a yet another devpts mount option which
explicitly stated that a new instance should be created. How do you
think if we do the same for rpc_pipefs (a newinstance mount option) and
add yet another mount option for its only client (nfs) telling it where
to look for the rpc mount for (e.g. rpcmount=/var/...) ?

>  3) Convert the nfs_client and superblock to be per-net namespace

Ack about the nfs_client, but as far as the superblock is
concerned - I think we should tag only the nfs_server with
net for the same reasons as in the item 2) above.

>  4) Convert lockd's struct host to be per-net namespace

Ack

> Cheers
>   Trond
> 
> 

