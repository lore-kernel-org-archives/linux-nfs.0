From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Comments on some of the work in NFS_ALL for 2.6.25
Date: Mon, 14 Jan 2008 18:26:02 -0500
Message-ID: <1200353162.12449.24.camel@heimdal.trondhjem.org>
References: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com>
	 <1200352256.12449.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:47381 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180AbYANX0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 18:26:06 -0500
In-Reply-To: <1200352256.12449.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-14 at 18:10 -0500, Trond Myklebust wrote:

> > I had carefully optimized the direct path so there was only a single  
> > pair of sigmask calls for each application I/O request, rather than  
> > one pair for every dispatched RPC.  With the rpc_run_task interface,  
> > we're now back to doing one pair for each RPC.  That seems like a  
> > step backwards to me...?
> 
> AFAICS, nfs_execute_read() dispatches only _one_ RPC call. Ditto for
> nfs_execute_write(). Those are the critical code paths...

In fact, if you are interested in optimising away sigmask calls, then
the first target should AFAICS be asynchronous RPC calls. Why set the
sigmask at all when doing reads and writes?

Cheers,
  Trond

