From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: asynchronous destroy messages
Date: Tue, 18 Mar 2008 19:27:34 -0400
Message-ID: <1205882854.15178.17.camel@heimdal.trondhjem.org>
References: <20080318221515.GE29948@fieldses.org>
	 <20080318223212.GA12362@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754442AbYCSTf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:35:29 -0400
In-Reply-To: <20080318223212.GA12362@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-18 at 18:32 -0400, J. Bruce Fields wrote:
> On Tue, Mar 18, 2008 at 06:15:15PM -0400, bfields wrote:
> > When an rpc client is shut down, gss destroy messages are sent out
> > asynchronously, and nobody waits for them.
> > 
> > If those rpc messages arrive after the client is completely shut down, I
> > assume they just get dropped by the networking code?  Is it possible for
> > them to arrive while we're still in the process of shutting down, and if
> > so, what makes this safe?
> 
> In other words--when does the task that's created to send the destroy
> message get freed, and if that doesn't happen till after the rpc client
> and associated objects are freed, is there a risk of someone trying to
> access those objects through fields in that task?
> 
> --b.

Are you talking about the rpc_task? That gets destroyed in the normal
fashion, and since the collection of all rpc_tasks should hold a
reference to the rpc_client, there shouldn't normally be any ordering
problems there.

Note however that we do some magic in 'rpc_free_auth' to extend the
natural lifetime of the rpc_client beyond that of the NFS 'shutdown'.

> > Olga's seeing some odd oopses on shutdown after testing our gss callback
> > code.  And of course it's probably our callback patches at fault, but I
> > was starting to wonder if there was a problem with those destroy
> > messages arriving at the wrong moment.  Any pointers welcomed.
> > 
> > --b.

Is the new code touching the destroy path? If so, how, and what are the
new assumptions that are being made?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
