Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54682 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcEJHEV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2016 03:04:21 -0400
Date: Tue, 10 May 2016 00:04:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160510070421.GB30896@infradead.org>
References: <20160508083543.GA14316@infradead.org>
 <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <31651.1462798652@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <31651.1462798652@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 09, 2016 at 01:57:32PM +0100, David Howells wrote:
> > > AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
> > > filesystem to synchronise its attributes with the server.
> > > 
> > > AT_NO_ATTR_SYNC can be set in flags.  This will suppress synchronisation
> > > with the server in a network filesystem.  The resulting values should be
> > > considered approximate.
> > 
> > And what happens if neither is set?
> 
> It does what stat() does now, whatever that is for each fs.  The assumption is
> that this might be used to emulate stat() from userspace.  However, we want to
> be able to make sure we get the two behaviours above.

And why would you emulate stat if we already have a perfectly working
version of it?  Either way we need to document what that behavior is,
and why userspace would chose one of the three options.

> > > mask is a bitmask indicating the fields in struct statx that are of
> > > interest to the caller.  The user should set this to STATX_BASIC_STATS to
> > > get the basic set returned by stat().
> > 
> > No a very good name for the constant.  I don't really see how this macro
> > is useful to start with.
> 
> It's the bits that correspond to all the data in the the current stat struct.
> So if you want to emulate stat(), you should pass this in mask.

which of the many stat version supported by Linux or glibc (nevermind other
OSes)?  And why would you care about that, as you could just use stat in
that case?  And even if you really cared how do you know what attributes
are "basic" if we don't properly document that?  And last but not least
why would the caller of the syscall (various libcs) care to get this
constant instead of defining it on it's own based on what ABI it
exports?

> > > 	STATX_GEN		Want/got st_gen
> > > 	STATX_ALL_STATS		[All currently available stuff]
> > 
> > Where does the STATS_ come from?  Why no simply _ALL?
> 
> Why not STATX_ALL_STATS?

Because it's the only places STATS or stats is used in the whole
interface.  It also doesn't match our common use for stats (as in
statistics, not fields of a stat-like structure)
