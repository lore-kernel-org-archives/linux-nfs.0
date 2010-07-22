Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757979Ab0GVMZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 08:25:47 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.LSU.2.01.1007221248050.9353@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1007221248050.9353@obet.zrqbmnf.qr> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <20100718084824.GA27794@infradead.org>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: dhowells@redhat.com, Christoph Hellwig <hch@infradead.org>,
        viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, drepper@redhat.com,
        torvalds@linux-foundation.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Thu, 22 Jul 2010 13:25:31 +0100
Message-ID: <30638.1279801531@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Jan Engelhardt <jengelh@medozas.de> wrote:

> >> (8) Allow the filesystem to indicate what it can/cannot provide: A
> >>     filesystem can now say it doesn't support a standard stat feature if
> >>     that isn't available.
> >
> >What for?
> 
> Given xstat.otime=0, how would you determine whether the file is really 
> tagged with a date of 1970, or whether it's just the fs which didnot 
> store this kind of information.

I was thinking more of stuff that's already in the Linux stat struct, some of
which is fabricated because the underlying fs doesn't support it.

Take RomFS for example: it fabricates all of st_mtime, st_atime, st_ctime,
st_nlinks, st_blocks, st_uid and st_gid because none of them are stored in the
medium

Similarly, UbiFS fabricates st_blocks and complains in a comment that it makes
no sense for that type of filesystem.

There are other examples.

David
