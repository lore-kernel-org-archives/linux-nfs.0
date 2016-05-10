Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33451 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbcEJNVJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2016 09:21:09 -0400
Received: by mail-qk0-f173.google.com with SMTP id n63so6251747qkf.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 May 2016 06:21:09 -0700 (PDT)
Message-ID: <1462886465.20038.6.camel@poochiereds.net>
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Date: Tue, 10 May 2016 09:21:05 -0400
In-Reply-To: <20160510070044.GA30896@infradead.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
	 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
	 <20160508083543.GA14316@infradead.org>
	 <1462795378.4481.31.camel@poochiereds.net>
	 <20160510070044.GA30896@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-05-10 at 00:00 -0700, Christoph Hellwig wrote:
> On Mon, May 09, 2016 at 08:02:58AM -0400, Jeff Layton wrote:
> > > > AT_FORCE_ATTR_SYNC can be set in flags.????This will require a
> > > > network
> > > > filesystem to synchronise its attributes with the server.
> > > > 
> > > > AT_NO_ATTR_SYNC can be set in flags.????This will suppress
> > > > synchronisation
> > > > with the server in a network filesystem.????The resulting
> > > > values should be
> > > > considered approximate.
> > > 
> > > And what happens if neither is set?
> > > 
> > 
> > I'd suggest we have the documentation state that the lack of either
> > flag leaves it up to the filesystem. In the case of NFS, you'd get
> > "normal" attribute cache behavior, for instance which is governed
> > by
> > the ac* attributes.
> > 
> > We should also note that in the case of something like
> > AT_NO_ATTR_SYNC
> > on NFS, you might _still_ end up talking to the server if the
> > client
> > has nothing in-core for that inode.
> 
> File systems specific "legacy" defaults are a bad idea.  If we can't
> describe the semantics we should not allow them, never mind making
> the the default.  I'd strongly suggest picking one of the above flags
> as the default behavior and only allowing the other as optional flag.
> I suspect NO_SYNC is the better one for the flag, as otherwise people
> will be surprised once they test their default case on a network
> filesystem.

Ok, that's a good point. So basically you suggest that xstat should
always have FORCE_SYNC semantics unless the NO_SYNC flag is set? Given
that we don't need to worry about legacy users with this interface,
that seems like a reasonable approach to me.
 
-- 
Jeff Layton <jlayton@poochiereds.net>
