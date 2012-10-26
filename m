Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:57877 "EHLO
	imap.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966544Ab2JZVPy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 17:15:54 -0400
Date: Fri, 26 Oct 2012 17:15:42 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Nix <nix@esperi.org.uk>
Cc: Eric Sandeen <sandeen@redhat.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Re: Apparent serious progressive ext4 data corruption bug in 3.6.3
 (and other stable branches?)
Message-ID: <20121026211542.GE8614@thunk.org>
References: <87objupjlr.fsf@spindle.srvr.nix>
 <20121023013343.GB6370@fieldses.org>
 <87mwzdnuww.fsf@spindle.srvr.nix>
 <20121023143019.GA3040@fieldses.org>
 <874nllxi7e.fsf_-_@spindle.srvr.nix>
 <87pq48nbyz.fsf_-_@spindle.srvr.nix>
 <508AF3FA.4020506@redhat.com>
 <87wqydx957.fsf@spindle.srvr.nix>
 <20121026205618.GC8614@thunk.org>
 <87objpx84k.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87objpx84k.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> This isn't the first time that journal_checksum has proven problematic.
> It's a shame that we're stuck between two error-inducing stools here...

The problem is that it currently bails out be aborting the entire
journal replay, and the file system will get left in a mess when it
does that.  It's actually safer today to just be blissfully ignorant
of a corrupted block in the journal, than to have the journal getting
aborted mid-replay when we detect a corrupted commit.

The plan is that eventually, we will have checksums on a
per-journalled block basis, instead of a per-commit basis, and when we
get a failed checksum, we skip the replay of that block, but we keep
going and replay all of the other blocks and commits.  We'll then set
the "file system corrupted" bit and force an e2fsck check.

The problem is this code isn't done yet, and journal_checksum is
really not ready for prime time.  When it is ready, my plan is to wire
it up so it is enabled by default; at the moment, it was intended for
developer experimentation only.  As I said, it's my fault for not
clearly labelling it "Not for you!", or putting it under an #ifdef to
prevent unwary civilians from coming across the feature and saying,
"oooh, shiny!" and turning it on.  :-(

					- Ted
