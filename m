Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55498 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753084Ab2CUUu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 16:50:27 -0400
Date: Wed, 21 Mar 2012 16:50:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: krb5 failures in recent nfs-for-next
Message-ID: <20120321205023.GC12309@fieldses.org>
References: <20120321192448.GB11222@fieldses.org>
 <4F6A2DE8.6060403@netapp.com>
 <20120321194544.GC11222@fieldses.org>
 <1332359824.12332.2.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332359824.12332.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 07:57:03PM +0000, Myklebust, Trond wrote:
> On Wed, 2012-03-21 at 15:45 -0400, J. Bruce Fields wrote:
> > On Wed, Mar 21, 2012 at 03:37:12PM -0400, Bryan Schumaker wrote:
> > > On 03/21/2012 03:24 PM, J. Bruce Fields wrote:
> > > 
> > > > Have you been doing any krb5 testing?
> > > 
> > > 
> > > Not yet.  It's still on my Jenkins todo list, but I haven't gotten around to it yet.  Sounds like we need it, though, so I'll try working on it soon.
> > 
> > Actually, I've since seen the failure over nfsv4 and auth_sys.  All
> > that's left on the console is enough to tell me it's happening in
> > nfs4_free_lock_state, called from __rpc_execute in a kthread.  (Well,
> > assuming that's actually the first backtrace.)
> 
> I've just been slow to update nfs-for-next. There has been a fix for
> this in the 'devel' and 'linux-next' branches for a while. Pushed out
> now...
> 
> The actual commitdiff is here:
>   http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=5ae67c4fee869c9b3c87b727a9ea511b6326b834

Thanks!

And that tree's stable, right?

In which case if you've no objection I'll likely merge it with a note
that I need it (well, some of the container changes) for jlayton's
reboot recovery patches.

--b.
