Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:52786 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbbK2Va5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Nov 2015 16:30:57 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: David Howells <dhowells@redhat.com>, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Date: Sun, 29 Nov 2015 22:30:39 +0100
Message-ID: <2872067.shHdUXoF07@wuerfel>
In-Reply-To: <20151129024555.GA31968@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <3495329.crWmoA5ACn@wuerfel> <20151129024555.GA31968@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday 28 November 2015 21:45:55 Theodore Ts'o wrote:
> On Tue, Nov 24, 2015 at 09:10:53PM +0100, Arnd Bergmann wrote:
> > On Tuesday 24 November 2015 14:36:46 Theodore Ts'o wrote:
> > > This is the patch I would prefer to use (and in fact which I have
> > > added to the ext4 tree):
> > > 
> > > There are issues with 32-bit vs 64-bit encoding of times before
> > > January 1, 1970, which are handled with this patch which is not
> > > handled with what you have in your patch series.  So I'd prefer if you
> > > drop this patch, and I'll get this sent to Linus as a bug fix for 4.4.
> > 
> > I'm happy with either one. Apparently both Davids have arrived with
> > almost the same algorithm and implementation, with the exception of
> > the pre-1970 handling you mention there.
> 
> I was doing some testing on x86, which leads me to ask --- what's the
> current thinking about post y2038 on 32-bit platforms such as x86?  I
> see that there was some talk about using struct timespec64, but we
> haven't made the transition in the VFS interfaces yet, despite a
> comment in an LWN article from 2014 stating that "the first steps have
> been taken; hopefully the rest will follow before too long".

The approach in my initial VFS series was to introduce 'struct inode_time',
but I have basically abandoned that idea now, after we decided to introduce
'timespec64' inside of the kernel and use that for other subsystems.
The rought plan is now to have separate time64_t and u32 seconds/nanoseconds
values in 'struct inode', 'struct iattr' and 'struct kstat' and use
inline functions or macros to extract or set them as time64_t or timespec64
in file system code, but that code is not written yet.

I'm mostly coordinating the y2038 work at the moment, but that means that
a lot of the work is going into individual drivers that a single person
can easily handle. We've had a couple of people who tried looking at VFS,
but none of them followed through, so it got delayed a bit. However,
Deepa Dinamani is now looking y2038 for VFS and individual file systems
as part of her Outreachy internship and I'm optimistic that we'll soon
be making progress again here with her work.

The other large missing piece is the system call implementation. I have
posted a series earlier this year before my parental leave, and it's
currently lacking review from libc folks, and blocked on me to update
the series and post it again.

	Arnd
