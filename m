Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43816 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab3K0Lkg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 06:40:36 -0500
Date: Wed, 27 Nov 2013 03:40:34 -0800
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/3] statxat: Provide IOC flags for Windows fs attributes
Message-ID: <20131127114034.GA13491@infradead.org>
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
 <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131112173526.25813.85546.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 12, 2013 at 05:35:26PM +0000, David Howells wrote:
> Provide IOC flags for Windows fs attributes so that they can be retrieved (or
> even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statxat().

As mentioned before we're running out of these flags and we already have
a horrible mash up between filesystem specific implementation details
an generally useful ones, so if you want to add them to a stat-like
call you better define an entirely new namespaces.

Also each of the added ones needs a good justification either way.

