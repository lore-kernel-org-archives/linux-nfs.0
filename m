Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565AbbKZPTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Nov 2015 10:19:50 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20151124081149.GA8840@infradead.org>
References: <20151124081149.GA8840@infradead.org> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, arnd@arndb.de, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Nov 2015 15:19:43 +0000
Message-ID: <7342.1448551183@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> from a quick look the statx bits looks fine in general.  I think Ted
> last time had a problem with the IOC flag allocation, so you might
> want to ping him.

Yeah - he commented on that.

> But fsinfo with the multiplexer and the void pointer is just horrible.
> What were you thinking there?

I think the fsinfo data struct probably wants splitting up.  Now this could be
done in a number of ways, including:

 (1) By adding multiple syscalls (statfsx, fsinfo, netfsinfo, ...) but each
     one needs a bit in the kernel to handle the basics (path/fd lookup,
     security check, buffer allocation and freeing, ...) which could all be in
     common - hence the mux method.

 (2) Adding an argument to the fsinfo syscall since it has at least one
     syscall argument spare.

 (3) Offloading some of the bits to standardised xattr calls.  The large
     string fields (domain name, volume name, ...) would seem to be obvious
     candidates for this.

Given that the core VFS gets to manage the contents of the buffer, it
shouldn't be as controversial as pioctl().

David
