Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1458 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933413Ab1IIU6n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 16:58:43 -0400
Message-ID: <4E6A7DE2.7000808@parallels.com>
Date: Sat, 10 Sep 2011 00:58:10 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>	 <20110909120844.13697.48102.stgit@localhost6.localdomain6>	 <20110909100745.7e2e8bf9@corrin.poochiereds.net>	 <4E6A41D4.6090001@parallels.com>	 <1315593874.17611.19.camel@lade.trondhjem.org>	 <20110909150104.5a83c60d@tlielax.poochiereds.net> <1315596308.17611.46.camel@lade.trondhjem.org>
In-Reply-To: <1315596308.17611.46.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Isn't the problem that Stanislav is trying to solve that we need to be
> able to register and unregister RPC services to the correct rpcbind
> server, depending on which net namespace we are in?
> 
> My understanding is that the current code will register everything to
> whatever rpcbind server is running in the init net namespace because
> that's what rpcb_create_local() uses.
> 
> My suggestion is to use a struct pernet_operations to detect when a net
> namespace is being created or destroyed, so that the rpcbind client code
> knows when to create or destroy a connection to the server that is
> running in that namespace.

The problem is that the client has a reference on transport, the transport gets
a socket and the socket holds the net namesace and thus we will not receive the
net->exit event with this approach.

Another option is to break the client's socket reference and kill the rpcb client
on netns stop (i.e. as you propose), but in that case we have another problem - 
how to destroy _other_ clients (not rpc bind ones) when the net namespace stops.

If you prefer either way just let us know, we'll fix the patches.

> Cheers
>   Trond

