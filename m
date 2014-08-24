Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:39065 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704AbaHXTSm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Aug 2014 15:18:42 -0400
Date: Sun, 24 Aug 2014 21:18:39 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <openosd@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/19] pnfs: force a layout commit when encountering
	busy segments during recall
Message-ID: <20140824191839.GA9717@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-4-git-send-email-hch@lst.de> <53FA259C.9050807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53FA259C.9050807@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 08:49:16PM +0300, Boaz Harrosh wrote:
> I've been sitting on client RECALL bugs over a year NOW. I have you scenario
> but actually a real DEAD-LOCK instead of an annoying delay.

A sufficiently long delay is undistinguishable from a deadlock :)

> * Client is doing a LAYOUT_GET and is returned RECALL_CONFLICT
> 
>   Comment: If your server is serious about it's recalls, then all the
>   while a recall is in progress it will return RECALL_CONFLICT on any
>   segment in conflict with the RECALL.

It does.

>   In objects layout this is easy to hit, because the LAYOUT_GET itself
>   may cause the issue of the RECALL, because if the objects map grows
>   do to the current LAYOUT_GET then all clients are RECALLed including
>   the one issuing the call.

RFC5663 also requires recalls from layoutget in certain cases.  The language
in is rather vague though, and I did chose to interpret it that the client
is responsible for coherency management on it's outstanding layouts, and thus
I will only recall layouts from other clientids.  Without that utter madness
would happen with the forgetful client model that Linux uses.

>   But this can also happen when one client caused an operation that
>   sends a RECALL on our client while our client is in the middle of
>   issuing a LAYOUT_GET.

This is something I could hit a well.  Might be worth to write a reproducer
(I've been trying to play a bit with pynfs, but it still confuses the heck
out of me)

> 1. I do the pnfs_layoutcommit_inode() regrdless of busy segments because
>    if it has-nothing-to-do it returns right-away. Segments may be busy
>    because of need-to-commit but also because they are used by in-flight-IO
>    So busy segments are not an exact indication.
>    In any way we can always do pnfs_layoutcommit_inode() to kick a LAYOUTCOMMIT
>    it will never do any harm.

Sounds fine to me.

> 2. This has a performance advantage, any segments held by LAYOUTCOMMIT will
>    now be freed, and the RECALL will return success instead of forcing the
>    server to one or more RECALL rounds with ERR_DELAY.

Sounds good to me as well.

> Also with my patch I hit races in state management, because my patch waits
> for LAYOUT_COMMIT to execute synchronously from the RECALL thread, your
> patch of  asynchronous LAYOUT_COMMIT has a lower chance of hitting. But I
> think Trond might have fixed these races, as I have tested this code like
> 6 month a go.

I've been running into various stateid handling problems, of which some
could be considered races.  Look at the other patches in this series - two of
those only appeared in the second iteration as they were only causing
MDS fallbacks, but no actual data corruption.

> If you are up to it you might want to test my synchronous way and see if you like
> things better. I'm testing your code as well to see how it looks.

Can you send me a full patch?  Either against mainline or my tree is fine.

> BTW: It looks like the hch-pnfs/getdeviceinfo has some of the pnfs fixes but that
> the hch-pnfs/blocklayout-for-3.18 has newer fixes but without the getdeviceinfo
> stuff. I'm testing with the older getdeviceinfo branch.

The getdeviceinfo as of now is missing two stateid handling fixes.  It was
based on blocklayout-for-3.18 when I pushed it out, but I have since updated
blocklayout-for-3.18.  I will push out a rebased getdeviceinfo branch later
today.

