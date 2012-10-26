Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:43176 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966481Ab2JZU7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2012 16:59:18 -0400
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
Date: Fri, 26 Oct 2012 21:59:07 +0100
In-Reply-To: <20121026205618.GC8614@thunk.org> (Theodore Ts'o's message of
	"Fri, 26 Oct 2012 16:56:18 -0400")
Message-ID: <87objpx84k.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26 Oct 2012, Theodore Ts'o stated:

> On Fri, Oct 26, 2012 at 09:37:08PM +0100, Nix wrote:
>> 
>> I can reproduce this on a small filesystem and stick the image somewhere
>> if that would be of any use to anyone. (If I'm very lucky, merely making
>> this offer will make the problem go away. :} )
>
> I'm not sure the image is going to be that useful.  What we really
> need to do is to get a reliable reproduction of what _you_ are seeing.
>
> It's clear from Eric's experiments that journal_checksum is dangerous.
> 
> That's why one of the things I asked you to do when you had time was
> to see if you could reproduce the problem you are seeing w/o
> nobarrier,journal_checksum,journal_async_commit.

OK. Will do tomorrow.

> The other experiment that would be really useful if you could do is to
> try to apply these two patches which I sent earlier this week:
>
> [PATCH 1/2] ext4: revert "jbd2: don't write superblock when if its empty
> [PATCH 2/2] ext4: fix I/O error when unmounting an ro file system
>
> ... and see if they make a difference.

As of tomorrow I'll be able to reboot without causing a riot: I'll test
it then. (Sorry for the delay :( )

>                                               So I really don't want
> to push these patches to Linus until I get confirmation that they make
> a difference to *somebody*.

Agreed.

This isn't the first time that journal_checksum has proven problematic.
It's a shame that we're stuck between two error-inducing stools here...

-- 
NULL && (void)
