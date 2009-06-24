From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 37/44] nfsd41: sunrpc: Added rpc server-side
	backchannel handling
Date: Wed, 24 Jun 2009 16:05:58 -0400
Message-ID: <20090624200558.GV14503@fieldses.org>
References: <1245115259-8023-1-git-send-email-bhalevy@panasas.com> <20090622181954.GB19619@fieldses.org> <4A406C55.5030008@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:49329
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbZFXUF7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2009 16:05:59 -0400
In-Reply-To: <4A406C55.5030008@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23, 2009 at 08:47:01AM +0300, Benny Halevy wrote:
> On Jun. 22, 2009, 21:19 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > By the way, apologies, I believe these are quite close, but the merge
> > window is closing and I need to help with the move, so this will have to
> > be queued for 2.6.32.  I'll start doing that as soon as I can.
> 
> Sigh, bad timing.
> Given the depth of your review we should definitely have had
> to start reviewing this code much sooner.

I'd saw "slowness" rather than depth!  And some bad planning on my part.

Anyway, one thing that would help would be just to make sure it's very
clear what the final version of a patch series is.  If I'm not sure, I'm
likely to procrastinate.

Also other things being equal if it's possible to sequence series with
easy bugfixes at the front, then I'm more likely to start in on them....

--b.

> > Also I'm aware there are some more bugfixes that should really go into
> > 2.6.31; if I haven't dealt with those by the end of the week, please
> > complain.
> 
> Thanks.  I'll follow up on that too.
> 
> Benny
> 
> > 
> > --b.
