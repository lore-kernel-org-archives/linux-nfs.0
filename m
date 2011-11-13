Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:48005 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab1KMSGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Nov 2011 13:06:38 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Sun, 13 Nov 2011 11:06:37 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pADI6Zup155730
	for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2011 11:06:35 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pADI6Ygh026558
	for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2011 11:06:35 -0700
Date: Sun, 13 Nov 2011 13:06:33 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111113180633.GA4084@Gelgoog.pok.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111113145400.6c7a9be3@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 13, 2011 at 02:54:00PM +1100, NeilBrown wrote:
> On Sat, 12 Nov 2011 09:49:53 -0500 Christoph Hellwig <hch@infradead.org>
> wrote:
> 
> > On Fri, Nov 11, 2011 at 07:13:29PM -0500, Trond Myklebust wrote:
> > > On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote: 
> > > > This patch series implements client side support for volatile file handle
> > > > recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
> > > > test the client you either need a server that supports volatile file handles or 
> > > > you can hard code the server to output NFS4ERR_FHEXPIRED instead of
> > > > NFSERR_STALE. (See the last patch in the series)
> > > 
> > > WHY do we want to support this kind of "feature"? As you said, the RFC
> > > doesn't actually help in figuring out how this crap is supposed to work
> > > in practice, so why do we even consider starting to give a damn?
> > 
> > *nod*. Pretending we handle it seems fairly dangerous.  I'd much prefer
> > outright rejecting it.
> 
> Hence the suggested mount option.
> 
> A server might not be able to provide stable file handles, but can ensure
> that files don't get renamed - for these filesystems, the name is a
> reliable stable handle for the file (it just doesn't fit in the NFSv4 file
> handle structure).
> 
> So if you know the filesystem will only return FHEXPIRED for filehandles
> belonging to files that cannot be renamed, then it is perfectly reasonable to
> repeat the name lookup to re-access the file after the server forgets about
> an old filehandle.  The mount option is how you communicate this knowledge,
> because the RFC doesn't provide a way to communicate it.
> 
This was one of 2 reasons for implementing this, and we actually run into this with 
certain z/OS systems, because the z/OS NFS server currently uses FHEXPIRED in this way.

The other thought was that this could be used for migration/replication 
between file synced servers. So, if we wanted to switch/move to another server where 
the file names were the same but all the inode numbers were different you could use 
this to refresh the invalid file handles on the new server.

-Matt Treinish


