From: Andi Kleen <andi@firstfloor.org>
Subject: Re: ->migratepage aops for nfs missing
Date: Wed, 5 Aug 2009 16:11:48 +0200
Message-ID: <20090805141148.GL11385@basil.fritz.box>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org> <20090804202648.GA12484@basil.fritz.box> <25558.1249423367@redhat.com> <1249423594.12510.0.camel@heimdal.trondhjem.org> <1249430567.12510.3.camel@heimdal.trondhjem.org> <20090805073036.GC11385@basil.fritz.box> <1249474573.5385.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35506 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934240AbZHEOLs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:11:48 -0400
In-Reply-To: <1249474573.5385.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2009 at 08:16:13AM -0400, Trond Myklebust wrote:
> On Wed, 2009-08-05 at 09:30 +0200, Andi Kleen wrote:
> > > Make NFS a bit more NUMA-friendly...
> > 
> > Minor nit :- page migration is not only used for NUMA.
> > 
> > -Andi
> 
> How about "Make NFS a bit more NUMA and memory hot removal-friendly..."?
> :-)

Thanks. Looks better.

But I'm actually adding a third user soon which is neither.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
