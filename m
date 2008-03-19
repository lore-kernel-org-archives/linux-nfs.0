From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous destroy messages
Date: Wed, 19 Mar 2008 11:57:27 -0400
Message-ID: <20080319155727.GA25636@fieldses.org>
References: <20080318221515.GE29948@fieldses.org> <47E1203B.7050201@citi.umich.edu> <1205937584.8388.40.camel@heimdal.trondhjem.org> <47E12A56.20703@citi.umich.edu> <1205941115.8388.81.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964983AbYCSWc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 18:32:29 -0400
In-Reply-To: <1205941115.8388.81.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 19, 2008 at 11:38:35AM -0400, Trond Myklebust wrote:
> 
> On Wed, 2008-03-19 at 10:59 -0400, Olga Kornievskaia wrote:
> > 
> > Trond Myklebust wrote:
> > > On Wed, 2008-03-19 at 10:16 -0400, Olga Kornievskaia wrote:
> > >   
> > >> J. Bruce Fields wrote:
> > >>     
> > >>> When an rpc client is shut down, gss destroy messages are sent out
> > >>> asynchronously, and nobody waits for them.
> > >>>
> > >>> If those rpc messages arrive after the client is completely shut down, I
> > >>> assume they just get dropped by the networking code?  Is it possible for
> > >>> them to arrive while we're still in the process of shutting down, and if
> > >>> so, what makes this safe?
> > >>>
> > >>> Olga's seeing some odd oopses on shutdown after testing our gss callback
> > >>> code.  And of course it's probably our callback patches at fault, but I
> > >>> was starting to wonder if there was a problem with those destroy
> > >>> messages arriving at the wrong moment.  Any pointers welcomed.
> > >>>
> > >>>   
> > >>>       
> > >> What I'm seeing is that nfs4_client structure goes away while an 
> > >> rpc_client is still active. nfs4_client and rpc_client share a pointer 
> > >> to the rpc_stat structure. so when nfs4_client memory goes away, the 
> > >> rpc_client oopses trying to dereference something within cl_stats.
> > >>
> > >> put_nfs4_client() causes rpc_shutdown_client() causes an async destroy 
> > >> context message. that message shares the rpc_stats memory with the 
> > >> nfs4_client memory that is currently being released. since the task is 
> > >> asynchronous, put_nfs4_client() completes and memory goes away. the task 
> > >> that's handling destroy context message wakes up (usually in 
> > >> call_timeout or call_refresh) and tries to dereference cl_stats.
> > >>     
> > >
> > > clnt->cl_stats is supposed to point to a statically allocated structure
> > >   
> > that is not true for the callback. look at do_probe_callback().
> 
> I can see why the rpc_program may needs to change, since the client
> doesn't know a priori what program number the client will choose, but
> why is there a need for a dynamically allocated cb->cb_stat?

I agree--it's not necessary.  I was delaying changing that just because
I was confused as to why that memory was still being used after
rpc_shutdown_client() returned.  Now I understand--thanks.

But are you sure the module-unload race isn't a concern?  Unloading the
nfs module soon after the last nfs mount might not be so rare, and those
tasks could hang around for quite a while, right?

--b.
