Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33356 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab0IMRuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Sep 2010 13:50:21 -0400
Date: Mon, 13 Sep 2010 13:49:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Message-ID: <20100913174917.GB16253@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
 <20100830175728.GA18764@fieldses.org>
 <20100907050142.GA14584@fieldses.org>
 <20100907051241.GB14584@fieldses.org>
 <1284325666.11048.69.camel@heimdal.trondhjem.org>
 <20100912234748.GC9402@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100912234748.GC9402@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Sep 12, 2010 at 07:47:48PM -0400, J. Bruce Fields wrote:
> On Sun, Sep 12, 2010 at 05:07:46PM -0400, Trond Myklebust wrote:
> > On Tue, 2010-09-07 at 01:12 -0400, J. Bruce Fields wrote:
> > > From: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > If rpc_queue_upcall() adds a new upcall to the rpci->pipe list just
> > > after rpc_pipe_release calls rpc_purge_list(), but before it calls
> > > gss_pipe_release (as rpci->ops->release_pipe(inode)), then the latter
> > > will free a message without deleting it from the rpci->pipe list.
> > > 
> > > We will be left with a freed object on the rpc->pipe list.  Most
> > > frequent symptoms are kernel crashes in rpc.gssd system calls on the
> > > pipe in question.
> > > 
> > > We could just add a list_del(&gss_msg->msg.list) here.  But I can see no
> > > reason for doing all this cleanup here; the preceding rpc_purge_list()
> > > should have done the job, except possibly for any newly queued upcalls
> > > as above, which can safely be left to wait for another opener.
> > 
> > Hi Bruce,
> > 
> > Looking again at this issue, I think I see why the ->release_pipe() is
> > needed. While the call to rpc_purge_list() does indeed clear the list of
> > all those messages that are waiting for their upcall to complete, it
> > does nothing for the messages that have successfully been read by the
> > daemon, but are now waiting for a reply.
> 
> Doh!
> 
> > How about something like the patch below instead?
> 
> I read it over, and it looks sensible to me.
> 
> It's also survived a few testing iterations.  I'll give it a few more
> just out of paranoia, but would be surprised if they find the problem
> isn't resolved.

Indeed, no surprises; please pass those patches along whenever you're
ready.

--b.
