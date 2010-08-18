Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36176 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab0HRTZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 15:25:10 -0400
Date: Wed, 18 Aug 2010 21:25:08 +0200
From: Andi Kleen <andi@firstfloor.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andi Kleen <andi@firstfloor.org>, Neil Brown <neilb@suse.de>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Patrick J. LoPresti" <lopresti@gmail.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
Message-ID: <20100818192508.GC6567@basil.fritz.box>
References: <87aaolwar8.fsf@basil.nowhere.org>
 <20100817174134.GA23176@fieldses.org>
 <20100817182920.GD18161@basil.fritz.box>
 <20100817190447.GA28049@fieldses.org>
 <AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
 <20100817203941.729830b7@lxorguk.ukuu.org.uk>
 <20100817192937.GD26609@fieldses.org>
 <20100818155359.66b9ddb6@notabene>
 <20100818175040.GA6567@basil.fritz.box>
 <20100818185456.GD13050@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100818185456.GD13050@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 02:54:56PM -0400, J. Bruce Fields wrote:
> On Wed, Aug 18, 2010 at 07:50:40PM +0200, Andi Kleen wrote:
> > >  - nfsd updates it whenever it reads an mtime out of an inode that matches
> > >    current_fs_time to the granularity of 1/HZ.
> > 
> > That means you have a very very hot cache line on a larger system
> > if there are a lot of mtime changes. Probably a bad idea.
> 
> Only if those mtime changes are also followed immediately by nfsd reads
> of the mtime.

If multiple writers are changing the same location in quick succession 
you have a hot cache line that gets bounced around.  It doesn't need reads,
although reads make it even worse.

There's a lot of effort currently to make the VFS more parallel
and less synchronized and it would be bad again to regress here again.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
