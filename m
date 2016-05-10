Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296AbcEJIZ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2016 04:25:58 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20160510070421.GB30896@infradead.org>
References: <20160510070421.GB30896@infradead.org> <20160508083543.GA14316@infradead.org> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk> <31651.1462798652@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 10 May 2016 09:25:55 +0100
Message-ID: <6897.1462868755@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> > It does what stat() does now, whatever that is for each fs.  The
> > assumption is that this might be used to emulate stat() from userspace.
> > However, we want to be able to make sure we get the two behaviours above.
> 
> And why would you emulate stat if we already have a perfectly working
> version of it?  Either way we need to document what that behavior is,
> and why userspace would chose one of the three options.

Because it's not necessarily a perfectly working version of it.  See the Y2037
problem for example.

I was assuming that C libraries might want to update the struct stat and the
stat call() to provide fields that aren't currently there in Linux but are in
other OS's.  We could even dispense with older stat syscalls on new arches.

Admittedly, this means that you would have backwardly incompatible versions of
the C library and would have to version your interface, so it might be too
much effort.

However, if we're going to discard this possibility, we can make these
features available only to direct calls of extended stat.

David
