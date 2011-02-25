Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:33210 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751909Ab1BYDHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 22:07:55 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, npiggin@gmail.com
In-Reply-To: <20110224145947.GA22723@ZenIV.linux.org.uk>
References: <1295420817.3076.24.camel@perseus>
	 <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
	 <1298516618.2916.20.camel@perseus>
	 <20110224031439.GR22723@ZenIV.linux.org.uk>
	 <1298518137.2916.35.camel@perseus>
	 <20110224035836.GS22723@ZenIV.linux.org.uk>
	 <1298529260.2916.91.camel@perseus>
	 <20110224070724.GW22723@ZenIV.linux.org.uk>
	 <1298542053.3058.56.camel@perseus>
	 <20110224145947.GA22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 25 Feb 2011 11:07:46 +0800
Message-ID: <1298603266.3439.44.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 14:59 +0000, Al Viro wrote:
> On Thu, Feb 24, 2011 at 06:07:33PM +0800, Ian Kent wrote:
> > > I really don't like the look of autofs4_tree_busy(), BTW - you don't need
> > > RCU to get races here; just a plain chdir("../../.."); done by a process
> > > that sits deep enough in subtree you are checking can very well race with
> > > your check, so that your iterator gets through the new cwd before chdir()
> > > and through the old one after it...
> > 
> > Yes, that's a problem.
> > 
> > Previously the dcache_lock would have blocked on the dput() ... mmm, I'd
> > missed that so far, although Nick didn't talk with me about his changes
> > very much at all and I didn't pay enough attention to his patch series
> > along the way, oops!
> 
> Well...  In principle, you could mark all mountpoints in a tree as managed,
> have an "expiry search in progress" flag to stop everything in there while
> the expiry happens, then wait out all RCU walks in progress, then go ahead
> with your expiry checks.  Would that work for you?

That approach would solve the problem.

It was deliberate to not make all dentrys as managed to avoid function
calls to ->manage() where possible but that might not be possible.

The priority right now though is the BUG() I'm getting due to the
elevated reference.

It turns out that the missing dput() you spotted won't trigger unless
user space does something stupid and that's why it didn't show up in
testing before.

Anyway, recent printk output is pointing me at do_filp_open() so I'm
probably going to need to look closely at it. I'm still gathering printk
evidence but I think that pain is coming.

Ian

