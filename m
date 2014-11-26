Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39471 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbaKZCkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 21:40:08 -0500
Date: Tue, 25 Nov 2014 21:40:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when
 queueing a xprt for servicing
Message-ID: <20141126024007.GB17634@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <20141125162557.0893c44c@tlielax.poochiereds.net>
 <20141126000941.GF15033@fieldses.org>
 <20141125193818.3800fd0d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141125193818.3800fd0d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 07:38:18PM -0500, Jeff Layton wrote:
> On Tue, 25 Nov 2014 19:09:41 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > I understand that's a lot of
> > information.)  But it's nice to see some numbers at least.
> > 
> > (I wonder what the reason is for the odd shape in the 112-thread case
> > (descending slightly as the writes decrease and then shooting up when
> > they go to zero.)  OK, I guess that's what you get if you just assume
> > read-write contention is expensive and one write is slightly more
> > expensive than one read.  But then why doesn't it behave the same way in
> > the 56-thread case?)
> > 
> 
> Yeah, I wondered about that too.

I was also forgetting that these are percentage increases.

For the future something that gave just the before and after numbers
side-by-side might be easier to think about?

> There is some virtualization in use on the clients here (and it's
> vmware too), so I have to wonder if there's some variance in the
> numbers due to weirdo virt behaviors or something.
> 
> The good news is that the overall trend pretty clearly shows a
> performance increase.

Yep, sure.

--b.

> 
> As always, benchmark results point out the need for more benchmarks.
> 
> -- 
> Jeff Layton <jlayton@primarydata.com>
