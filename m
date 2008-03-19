From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous destroy messages
Date: Tue, 18 Mar 2008 22:40:29 -0400
Message-ID: <20080319024029.GB16152@fieldses.org>
References: <20080318221515.GE29948@fieldses.org> <20080318223212.GA12362@fieldses.org> <1205882854.15178.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964978AbYCSWca (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 18:32:30 -0400
In-Reply-To: <1205882854.15178.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 18, 2008 at 07:27:34PM -0400, Trond Myklebust wrote:
> 
> On Tue, 2008-03-18 at 18:32 -0400, J. Bruce Fields wrote:
> > On Tue, Mar 18, 2008 at 06:15:15PM -0400, bfields wrote:
> > > When an rpc client is shut down, gss destroy messages are sent out
> > > asynchronously, and nobody waits for them.
> > > 
> > > If those rpc messages arrive after the client is completely shut down, I
> > > assume they just get dropped by the networking code?  Is it possible for
> > > them to arrive while we're still in the process of shutting down, and if
> > > so, what makes this safe?
> > 
> > In other words--when does the task that's created to send the destroy
> > message get freed, and if that doesn't happen till after the rpc client
> > and associated objects are freed, is there a risk of someone trying to
> > access those objects through fields in that task?
> > 
> > --b.
> 
> Are you talking about the rpc_task? That gets destroyed in the normal
> fashion, and since the collection of all rpc_tasks should hold a
> reference to the rpc_client, there shouldn't normally be any ordering
> problems there.

Oh, OK, got it.  Like Ogla says, we were getting oopses due to
references to an rpc_stats structure that was freed on the assumption it
was safe to do so after rpc_shutdown_client() returned.

(In the case of the nfs client, the rpc_stats structure is declared
statically.  But isn't that memory freed when the module is removed?)

--b.

> 
> Note however that we do some magic in 'rpc_free_auth' to extend the
> natural lifetime of the rpc_client beyond that of the NFS 'shutdown'.
> 
> > > Olga's seeing some odd oopses on shutdown after testing our gss callback
> > > code.  And of course it's probably our callback patches at fault, but I
> > > was starting to wonder if there was a problem with those destroy
> > > messages arriving at the wrong moment.  Any pointers welcomed.
> > > 
> > > --b.
> 
> Is the new code touching the destroy path? If so, how, and what are the
> new assumptions that are being made?
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
