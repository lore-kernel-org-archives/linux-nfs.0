Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51425 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148Ab0JHRGX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Oct 2010 13:06:23 -0400
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Pavel Emelyanov <xemul@parallels.com>, dhowells@redhat.com
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <1285013116.2851.71.camel@heimdal.trondhjem.org>
References: <4C90BADB.10700@parallels.com>
	 <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com>
	 <20100920180418.GN4580@fieldses.org>  <4C97B248.1030801@parallels.com>
	 <1285013116.2851.71.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 13:06:02 -0400
Message-ID: <1286557562.18406.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-20 at 16:05 -0400, Trond Myklebust wrote: 
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
>  2) Convert rpc_pipefs to be per-net namespace.
>  3) Convert the nfs_client and superblock to be per-net namespace
>  4) Convert lockd's struct host to be per-net namespace

Actually, there is one more task that needs to be added to the above
list. We need to figure out what to do with the keyring upcalls.

The keyring upcalls are currently initiated through the same mechanism
as module_request and therefore get started with the init_nsproxy
namespace. We'd really like them to run inside the same container as the
process.
As part of the same problem, there is the issue of what to do with the
dns resolver and Bryan's new keyring based idmapper code.

Cheers
  Trond
