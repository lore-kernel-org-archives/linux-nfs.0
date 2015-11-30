Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:57474 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553AbbK3OQN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2015 09:16:13 -0500
Date: Mon, 30 Nov 2015 09:16:05 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Howells <dhowells@redhat.com>, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [PATCH 01/12] Ext4: Fix extended timestamp encoding and decoding
Message-ID: <20151130141605.GA4316@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <3495329.crWmoA5ACn@wuerfel>
 <20151129024555.GA31968@thunk.org>
 <2872067.shHdUXoF07@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2872067.shHdUXoF07@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 29, 2015 at 10:30:39PM +0100, Arnd Bergmann wrote:
> The other large missing piece is the system call implementation. I have
> posted a series earlier this year before my parental leave, and it's
> currently lacking review from libc folks, and blocked on me to update
> the series and post it again.

I assume that this also means there hasn't been much thought about
userspace support above libc?  i.e., how to take a 64-bit time64_t (or
changing the size of time_t) and translating that to a string using
some kind of version of ctime() and asctime(), and how to parse a
post-2038 date string and turning it into a 64-bit time_t on a 32-bit
platform?

The reason why I'm asking is because I'm thinking about how to add the
appropriate regression test support to e2fsprogs for 32-bit platforms.
I'm probably going to just skip the tests on architectures where
sizeof(time_t) == 4 for now, since with a 32-bit time_t adding support
for post-2038 in a e2fsprogs-specific way is (a) something I don't
have time for, and (b) probably a waste of time since presumably we
will either need to have a more general solution, or simply decide to
give up on 32-bit platforms by 2038....

Cheers,

   	       	     	    	      	 - Ted
