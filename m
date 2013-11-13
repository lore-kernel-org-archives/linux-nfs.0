Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759107Ab3KMSqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 13:46:44 -0500
Date: Wed, 13 Nov 2013 13:46:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131113184637.GM28033@fieldses.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
 <20131112194529.GA26341@fieldses.org>
 <52828767.3030909@netapp.com>
 <20131112195911.GA28033@fieldses.org>
 <5283A24D.4010309@netapp.com>
 <5283A3B7.8080405@netapp.com>
 <20131113161527.GA10046@infradead.org>
 <20131113164959.GL28033@fieldses.org>
 <20131113165204.GB8676@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131113165204.GB8676@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 08:52:04AM -0800, Christoph Hellwig wrote:
> On Wed, Nov 13, 2013 at 11:49:59AM -0500, J. Bruce Fields wrote:
> > This isn't a candidate for 3.13, and SEEK didn't look like the most
> > problematic bit, so with a couple more months I'm hoping we'll be more
> > confident about the protocol?
> 
> Wish I knew.  The ieft list seems to be at an awfully small pace,

It just varies depending on who's paying attention, I think.  Tom's
actually been taking changes pretty quickly once there's patches.

> and the actual spec seems another layer separated from that.  People
> who are more familar with the process might have to chime in.

Trond actually goes to those meetings on a regular basis, so he's
probably the one to chime in.

4.0 and 4.1 were both kind of huge and monolithic, and I don't remember
facing the problem of knowing when the specs were "done": the code
wasn't going to be ready before the rfc's were published anyway.

A lot of these 4.2 things look much simpler to implement, so now we've
got the option of releasing things into the wild before there's an rfc.
And if we screw up then we could end up sticking someone else with
behavior they don't want.

Better than specifying behavior that nobody wanted, which was more
likely before--it's good to be reviewing specs and patches at the same
time.  But now I'm more vague on when to declare some part of the new
spec stable.

If there's no magic milestone then we just review and communicate as
best we can, I guess....

--b.
