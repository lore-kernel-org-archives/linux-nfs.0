From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ->migratepage aops for nfs missing
Date: Wed, 05 Aug 2009 08:16:13 -0400
Message-ID: <1249474573.5385.0.camel@heimdal.trondhjem.org>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org>
	 <20090804202648.GA12484@basil.fritz.box> <25558.1249423367@redhat.com>
	 <1249423594.12510.0.camel@heimdal.trondhjem.org>
	 <1249430567.12510.3.camel@heimdal.trondhjem.org>
	 <20090805073036.GC11385@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34414 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933622AbZHEMQS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 08:16:18 -0400
In-Reply-To: <20090805073036.GC11385-u0/ZJuX+froe6aEkudXLsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-05 at 09:30 +0200, Andi Kleen wrote:
> > Make NFS a bit more NUMA-friendly...
> 
> Minor nit :- page migration is not only used for NUMA.
> 
> -Andi

How about "Make NFS a bit more NUMA and memory hot removal-friendly..."?
:-)



