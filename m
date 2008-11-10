From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 15:01:19 -0500
Message-ID: <1226347279.7599.47.camel@heimdal.trondhjem.org>
References: <20081109204621.GD27376@fieldses.org>
	 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
	 <1226344297.7599.41.camel@heimdal.trondhjem.org>
	 <20081110194900.GD19053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10383 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbYKJUBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 15:01:43 -0500
In-Reply-To: <20081110194900.GD19053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-10 at 14:49 -0500, J. Bruce Fields wrote:
> On Mon, Nov 10, 2008 at 02:11:37PM -0500, Trond Myklebust wrote:
> > On Sun, 2008-11-09 at 16:04 -0500, J. Bruce Fields wrote:
> > > I can't see any reason we particularly need to call this until the last
> > > gssd closes the pipe.
> > 
> > There's a very good reason: if we call rpc_close_pipes() then it is
> > because the kernel listener is shutting down. At that point, we want to
> > return EPIPE for all future read() or write() attempts by gssd.
> 
> Sure.  This doesn't interfere with that--we're still calling
> release_pipe() itself (which is the function that sets rpci->ops to
> NULL), it's only the ->release_pipe() op that we're not calling.
>
> > > Also, this allows to guarantee that open_pipe and release_pipe are
> > > called strictly in pairs; open_pipe on the first open, release_pipe on
> > > the last close.  That'll make it very easy for the gss code to keep
> > > track of which pipes gssd is using.
> > 
> > ...unless the gss code is no longer running.
> 
> I'm not following you.
> 
> Note the patch calls ->release_pipe() at close_pipe() time if there are
> still opens (and then subsequent closes become no-ops).  So it does
> guarantee that there's always a matching call.

No it doesn't. Now that rpci->ops has been set to NULL by
rpc_close_pipes(), exactly how are you going to call
rpci->ops->release_pipe() at a later time?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
