Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:63873 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933342Ab2J0DMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 23:12:08 -0400
Date: Fri, 26 Oct 2012 23:11:47 -0400
From: Jim Rees <rees@umich.edu>
To: "Theodore Ts'o" <tytso@mit.edu>, Nix <nix@esperi.org.uk>,
        Eric Sandeen <sandeen@redhat.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Re: Apparent serious progressive ext4 data corruption bug in 3.6.3
 (and other stable branches?)
Message-ID: <20121027031147.GA4255@umich.edu>
References: <20121023013343.GB6370@fieldses.org>
 <87mwzdnuww.fsf@spindle.srvr.nix>
 <20121023143019.GA3040@fieldses.org>
 <874nllxi7e.fsf_-_@spindle.srvr.nix>
 <87pq48nbyz.fsf_-_@spindle.srvr.nix>
 <508AF3FA.4020506@redhat.com>
 <87wqydx957.fsf@spindle.srvr.nix>
 <20121026205618.GC8614@thunk.org>
 <87objpx84k.fsf@spindle.srvr.nix>
 <20121026211542.GE8614@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121026211542.GE8614@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Theodore Ts'o wrote:

  The problem is this code isn't done yet, and journal_checksum is
  really not ready for prime time.  When it is ready, my plan is to wire
  it up so it is enabled by default; at the moment, it was intended for
  developer experimentation only.  As I said, it's my fault for not
  clearly labelling it "Not for you!", or putting it under an #ifdef to
  prevent unwary civilians from coming across the feature and saying,
  "oooh, shiny!" and turning it on.  :-(

Perhaps a word or two in the mount man page would be appropriate?
