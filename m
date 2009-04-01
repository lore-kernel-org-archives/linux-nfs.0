From: David Howells <dhowells@redhat.com>
Subject: Re: [GIT PULL] Please pull the first batch of NFS client changes (and cachefs merge)...
Date: Wed, 01 Apr 2009 18:24:25 +0100
Message-ID: <19756.1238606665@redhat.com>
References: <alpine.LFD.2.00.0904010935000.4130@localhost.localdomain> <1238522824.6577.5.camel@heimdal.trondhjem.org>
Cc: dhowells@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51375 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759443AbZDARZN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 13:25:13 -0400
In-Reply-To: <alpine.LFD.2.00.0904010935000.4130-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> And I also have a stupid trivial complaint:
> 
> WTF is up with absolutely inane crap like this:
> 
> >  fs/cachefiles/cf-bind.c                           |  286 +++++++
> >  fs/cachefiles/cf-daemon.c                         |  754 ++++++++++++++++++
> ...
> What the hell is that "cf-" and "fsc-" prefix?

One editor with many files open all of the same base name (namei.c, proc.c,
security.c, xattr.c, page.c for example).

Anyway...  I've fixed that with a bit of perl.

> I _really_ want fscache to come with way more Acked-by's etc. 

I'll try and get you some more Acks.

David
