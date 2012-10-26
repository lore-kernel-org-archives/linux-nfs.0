Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:40349 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966492Ab2JZVTa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2012 17:19:30 -0400
From: Nix <nix@esperi.org.uk>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: Eric Sandeen <sandeen@redhat.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Re: Apparent serious progressive ext4 data corruption bug in 3.6.3 (and other stable branches?)
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix>
	<20121023143019.GA3040@fieldses.org>
	<874nllxi7e.fsf_-_@spindle.srvr.nix>
	<87pq48nbyz.fsf_-_@spindle.srvr.nix> <508AF3FA.4020506@redhat.com>
	<87wqydx957.fsf@spindle.srvr.nix> <20121026205618.GC8614@thunk.org>
	<87objpx84k.fsf@spindle.srvr.nix> <20121026211542.GE8614@thunk.org>
Date: Fri, 26 Oct 2012 22:19:21 +0100
In-Reply-To: <20121026211542.GE8614@thunk.org> (Theodore Ts'o's message of
	"Fri, 26 Oct 2012 17:15:42 -0400")
Message-ID: <87haphx76u.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26 Oct 2012, Theodore Ts'o uttered the following:

> The plan is that eventually, we will have checksums on a
> per-journalled block basis, instead of a per-commit basis, and when we
> get a failed checksum, we skip the replay of that block,

But not of everything it implies, since that's quite tricky to track
down (it's basically the same work needed for softupdates, but in
reverse). Hence the e2fsck check, I suppose.

> prevent unwary civilians from coming across the feature and saying,
> "oooh, shiny!" and turning it on.  :-(

Or having it turned on by default either, which seems to be the case
now.

-- 
NULL && (void)
