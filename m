Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56874 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbcELJLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 05:11:42 -0400
Date: Thu, 12 May 2016 02:11:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160512091141.GA22420@infradead.org>
References: <20160510070421.GB30896@infradead.org>
 <20160508083543.GA14316@infradead.org>
 <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <31651.1462798652@warthog.procyon.org.uk>
 <6897.1462868755@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6897.1462868755@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 10, 2016 at 09:25:55AM +0100, David Howells wrote:
> Because it's not necessarily a perfectly working version of it.  See the Y2037
> problem for example.
> 
> I was assuming that C libraries might want to update the struct stat and the
> stat call() to provide fields that aren't currently there in Linux but are in
> other OS's.  We could even dispense with older stat syscalls on new arches.

Please stop this whole let's get rid of old syscalls on new
architectures stuff.  This just means we have to do the translation
multiple, and the one in userspace is more costly as we it needs to be
in every copy of the library.  And times where we had a single libc
instance (nevermind implementation) are long over if we ever actually
had them.

> However, if we're going to discard this possibility, we can make these
> features available only to direct calls of extended stat.

And even if we want to to do a stat emulation despite that above
argument let's add the flag once a major libc implementation actually
wants to use it and taylor it towards the use case.  Don't just add
it just because, and even more importantly don't make it the default.
