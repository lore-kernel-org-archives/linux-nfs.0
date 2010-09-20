Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab0ITULP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 16:11:15 -0400
Date: Mon, 20 Sep 2010 16:09:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Message-ID: <20100920200950.GB18808@fieldses.org>
References: <4C90BADB.10700@parallels.com>
 <20100920161326.GL4580@fieldses.org>
 <4C978CE6.5080508@parallels.com>
 <20100920180418.GN4580@fieldses.org>
 <4C97B248.1030801@parallels.com>
 <1285013116.2851.71.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285013116.2851.71.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 04:05:16PM -0400, Trond Myklebust wrote:
> On Mon, 2010-09-20 at 23:13 +0400, Pavel Emelyanov wrote:
> > On 09/20/2010 10:04 PM, J. Bruce Fields wrote:
> > > On Mon, Sep 20, 2010 at 08:33:42PM +0400, Pavel Emelyanov wrote:
> > >>>> Looking forward to your feedback.
> > >>>
> > >>> What are you thinking of as a use-case for this?
> > >>
> > >> To make it possible run both NFS server and client in containers.
> > > 
> > > Could you describe that in user-visible terms?  (Currently if I create a
> > > new network namespace, what happens, and what will happen differently
> > > afterwards?)
> > 
> > This is not about the network namespace only I believe. E.g. the
> > nfsd filesystem is a filesystem already and shouldn't be tied to
> > any task-driven context.
> > 
> > E.g. as far as the net namespace part is concerned. First of all
> > the TCP/UDP socket used by transport will be per-namespace. User
> > will "feel" this for example by different routing and netfilter
> > rules applied to connections. Besides the rpc service sockets will
> > be per namespace as well.
> > 
> > >> Sure! The thing is that the full containerization of that stuff is
> > >> too many patches and I'm not sure that you and other maintainers wish
> > >> to review the 100-patch set in one go ;)
> > > 
> > > Well, if it's really all ready....
> > > 
> > > Better, though, would be an outline of the work to be done and what you
> > > expect to be working at the end.
> > 
> > The nearest plan is
> > 
> > 1. Prepare the sunrpc layer to work in net namespaces
> > 2. Make rpcpipefs and nfsd filesystems be mountable multiple times
> > 3. Make support for multiple instances of the nfsd caches
> > 4. Make suuport for multiple instances of the nfsd_serv
> > 
> > After this several NFSd-s can be used in containers (hopefully I
> > didn't miss anything).
> > 
> > Plans about the nfs client are much more obscure for now.
> 
> The client should be something like the following:
> 
>  1) Ensure sunrpc sockets are created using the correct net namespace

For the client, that's initially the net namespace of the mount?  (What
about submounts?)

>  2) Convert rpc_pipefs to be per-net namespace.
>  3) Convert the nfs_client and superblock to be per-net namespace
>  4) Convert lockd's struct host to be per-net namespace

What do we expect behavior to actually look like from the point of view
of somebody on the client?

I'd like to see someone write some kind of spec for how this should all
work.  That worries me a lot more than the code.....

--b.
