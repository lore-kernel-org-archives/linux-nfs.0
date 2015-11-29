Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:55818 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbbK2CqF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Nov 2015 21:46:05 -0500
Date: Sat, 28 Nov 2015 21:45:55 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Howells <dhowells@redhat.com>, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Message-ID: <20151129024555.GA31968@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <20151120145434.18930.89755.stgit@warthog.procyon.org.uk>
 <20151124193646.GA3482@thunk.org>
 <3495329.crWmoA5ACn@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3495329.crWmoA5ACn@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2015 at 09:10:53PM +0100, Arnd Bergmann wrote:
> On Tuesday 24 November 2015 14:36:46 Theodore Ts'o wrote:
> > This is the patch I would prefer to use (and in fact which I have
> > added to the ext4 tree):
> > 
> > There are issues with 32-bit vs 64-bit encoding of times before
> > January 1, 1970, which are handled with this patch which is not
> > handled with what you have in your patch series.  So I'd prefer if you
> > drop this patch, and I'll get this sent to Linus as a bug fix for 4.4.
> 
> I'm happy with either one. Apparently both Davids have arrived with
> almost the same algorithm and implementation, with the exception of
> the pre-1970 handling you mention there.

I was doing some testing on x86, which leads me to ask --- what's the
current thinking about post y2038 on 32-bit platforms such as x86?  I
see that there was some talk about using struct timespec64, but we
haven't made the transition in the VFS interfaces yet, despite a
comment in an LWN article from 2014 stating that "the first steps have
been taken; hopefully the rest will follow before too long".

Cheers,

					- Ted
