From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bugme-new] [Bug 12564] New: poor performance while
 preprocessing source code
Date: Thu, 29 Jan 2009 08:27:36 -0500
Message-ID: <1233235656.9785.104.camel@heimdal.trondhjem.org>
References: <bug-12564-10286@http.bugzilla.kernel.org/>
	 <20090128132942.c957a199.akpm@linux-foundation.org>
	 <20090128170506.37161fb6@tleilax.poochiereds.net>
	 <1233190956.21519.13.camel@bluishred.int.infinisim.com>
	 <20090128173730.9e4b9f0b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steven Patrick <steven-m+eqe7hsN2k@public.gmane.org>, jlayton@redhat.com,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33902 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbZA2N14 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Jan 2009 08:27:56 -0500
In-Reply-To: <20090128173730.9e4b9f0b.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-01-28 at 17:37 -0800, Andrew Morton wrote:
> On Wed, 28 Jan 2009 17:02:36 -0800
> Steven Patrick <steven-m+eqe7hsN2k@public.gmane.org> wrote:
> 
> > On Wed, 2009-01-28 at 17:05 -0500, Jeff Layton wrote:
> > > 
> > > It's a pretty small patch. The obvious question is: "What mount
> > > options
> > > are you using on your NFS mounts?"
> > > 
> > 
> >   Well, I didn't think that I was using any NFS mounts.
> > But, it turns out I was in a way.  Apparently, amd does its top
> > level mounts with noac.  So, where this (using an automounted path):
> >     cd /h/spo/work
> >     make -j 5
> > would be slow.  This (using a non-automounted path):
> >     cd /home/spo/work
> >     make -j 5
> > showed the faster performance I was expecting.
> >   I will mark my bug as invalid and decide what, if anything,
> > I want to do about amd.
> >   Thanks for pointing me in the right direction.
> > 
> 
> This had me all mystified until I clicked on the bugzilla link:
> 
> 
> :  ------- Comment  #9 From Trond Myklebust  2009-01-28 13:58:50  [reply] -------
> : 
> : If you are worried about performance, why are you using noac/actimeo=0?
> : 
> : The commit you point to fixed a bug in which the noac/actimeo=0 was
> : using cached metadata in situations where it should have been
> : retrieving the data from the server.  We fully expect a significant
> : performance drop when the client is forced to send more GETATTR
> : requests to the server, and as I said, that was precisely the point of
> : this fix.
> 
> Fair enough.
> 
> 
> 
> However.  We surprised one user (yourself), and we will presumably
> surprise others.  Or, worse, we will slow down people's stuff and they
> won't even notice.
> 
> Should we perhaps warn people about this?  A mount-time printk telling
> them that moac/actime=0 is slow?

No. The current nfs manpages (dated 2 November 2007) have a whole
section on data and metadata coherence and about the trade-offs
involved. That section is explicitly referenced in the description of
the 'noac' mount option. It explains that 'noac' is basically about
disabling caching in order to achieve approximate cache coherent
behaviour when multiple NFS clients need to access files that are being
modified frequently on the server.

Note that 'noac' has _never_ been intended as a default NFS mount
option. The kernel default is rather to cache attributes as aggressively
as possible for scalability and performance reasons.
All other NFS mount programs therefore require 'noac' to be explicitly
set by the user. I see no reason to punish those users with extra printk
spam.

