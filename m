From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: asynchronous destroy messages
Date: Wed, 19 Mar 2008 10:39:44 -0400
Message-ID: <1205937584.8388.40.camel@heimdal.trondhjem.org>
References: <20080318221515.GE29948@fieldses.org>
	 <47E1203B.7050201@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756503AbYCSTfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:35:30 -0400
In-Reply-To: <47E1203B.7050201@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-19 at 10:16 -0400, Olga Kornievskaia wrote:
> 
> J. Bruce Fields wrote:
> > When an rpc client is shut down, gss destroy messages are sent out
> > asynchronously, and nobody waits for them.
> >
> > If those rpc messages arrive after the client is completely shut down, I
> > assume they just get dropped by the networking code?  Is it possible for
> > them to arrive while we're still in the process of shutting down, and if
> > so, what makes this safe?
> >
> > Olga's seeing some odd oopses on shutdown after testing our gss callback
> > code.  And of course it's probably our callback patches at fault, but I
> > was starting to wonder if there was a problem with those destroy
> > messages arriving at the wrong moment.  Any pointers welcomed.
> >
> >   
> What I'm seeing is that nfs4_client structure goes away while an 
> rpc_client is still active. nfs4_client and rpc_client share a pointer 
> to the rpc_stat structure. so when nfs4_client memory goes away, the 
> rpc_client oopses trying to dereference something within cl_stats.
> 
> put_nfs4_client() causes rpc_shutdown_client() causes an async destroy 
> context message. that message shares the rpc_stats memory with the 
> nfs4_client memory that is currently being released. since the task is 
> asynchronous, put_nfs4_client() completes and memory goes away. the task 
> that's handling destroy context message wakes up (usually in 
> call_timeout or call_refresh) and tries to dereference cl_stats.

clnt->cl_stats is supposed to point to a statically allocated structure
(in this case 'nfs_rpcstat'). While that can, in theory, disappear if
the user removes the NFS module, in practice that is very unlikely. I
therefore think you are rather seeing some sort of memory corruption
issue that is affecting the rpc_client.

Are you seeing this with the 'devel' branch from my git tree, or does it
only affect your patched kernel. If the latter, may we see your patches?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
