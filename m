Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40977 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754350AbZICSyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 14:54:11 -0400
Subject: Re: NFS for millions of files
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Peter Staubach <staubach@redhat.com>,
        Jason Legate <linux-nfs@proxime.net>, linux-nfs@vger.kernel.org
In-Reply-To: <4AA00CFF.6010304@redhat.com>
References: <20090902180841.GF946@proxime.net> <4A9EBB6B.4040009@redhat.com>
	 <20090903181535.GA10670@fieldses.org>  <4AA00CFF.6010304@redhat.com>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 14:54:00 -0400
Message-Id: <1252004040.18338.48.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-09-03 at 14:37 -0400, Ric Wheeler wrote:
> On 09/03/2009 02:15 PM, J. Bruce Fields wrote:
> > On Wed, Sep 02, 2009 at 02:37:31PM -0400, Peter Staubach wrote:
> >    
> >> Please keep in mind that the NFS stable storage requirements are
> >> probably causing a significant slowdown in activities such as this.
> >>      
> > My first thought too, but:
> >
> >    
> >> Jason Legate wrote:
> >>      
> >>> When I run our creation benchmark locally  I can get around 3000
> >>> files/ second in the configuration we're using now, but only around
> >>> 300/second over NFS.  It's mounted as this:
> >>>        
> > ...
> >    
> >>> When I mount the same FS over localhost instead of across the lan,
> >>> it performs about full speed (the 3000/sec).
> >>>        
> > The localhost NFS mount would be incurring the same sync latency, so all
> > his latency must be due to network.  (And with those numbers I guess
> > he's either got lots of disk spindles, or an ssd, or (uh-oh) has the
> > async option set?)
> >
> > --b.
> >    
> 
> For small files without doing an fsync per file, getting 3000 files/sec 
> is not that much. Ext3 can do it with a local s-ata disk. I suspect that 
> Jason would run much slower if he ran with local fsync()'s enabled 
> (similar to what NFS servers have to do).

Actually, NFS servers have to do _two_ fsyncs. One when creating the
file, and one when the client closes it. NFSv4 with write delegations
could allow the client to delay the fsync on close, but does not allow
it to eliminate the fsync-on-create.
In order help speed up those workloads we have therefore recently
submitted a proposal to also delay the fsync-on-create. This proposal is
for inclusion in the IETF's NFSv4 working group charter for NFSv4.2...

Cheers
  Trond

