From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 37/44] nfsd41: sunrpc: Added rpc server-side	backchannel
 handling
Date: Tue, 23 Jun 2009 08:47:01 +0300
Message-ID: <4A406C55.5030008@panasas.com>
References: <1245115259-8023-1-git-send-email-bhalevy@panasas.com> <20090622181954.GB19619@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:3257
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751076AbZFWFrD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2009 01:47:03 -0400
In-Reply-To: <20090622181954.GB19619@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 22, 2009, 21:19 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> By the way, apologies, I believe these are quite close, but the merge
> window is closing and I need to help with the move, so this will have to
> be queued for 2.6.32.  I'll start doing that as soon as I can.

Sigh, bad timing.
Given the depth of your review we should definitely have had
to start reviewing this code much sooner.

> 
> Also I'm aware there are some more bugfixes that should really go into
> 2.6.31; if I haven't dealt with those by the end of the week, please
> complain.

Thanks.  I'll follow up on that too.

Benny

> 
> --b.
