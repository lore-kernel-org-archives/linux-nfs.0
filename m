Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:55312 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaKZLMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 06:12:25 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so1891671qcx.30
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 03:12:24 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 26 Nov 2014 06:12:22 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] sunrpc: reduce pool->sp_lock contention when
 queueing a xprt for servicing
Message-ID: <20141126061222.2d375da1@tlielax.poochiereds.net>
In-Reply-To: <20141126024007.GB17634@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<20141125162557.0893c44c@tlielax.poochiereds.net>
	<20141126000941.GF15033@fieldses.org>
	<20141125193818.3800fd0d@tlielax.poochiereds.net>
	<20141126024007.GB17634@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 25 Nov 2014 21:40:07 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Nov 25, 2014 at 07:38:18PM -0500, Jeff Layton wrote:
> > On Tue, 25 Nov 2014 19:09:41 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > I understand that's a lot of
> > > information.)  But it's nice to see some numbers at least.
> > > 
> > > (I wonder what the reason is for the odd shape in the 112-thread case
> > > (descending slightly as the writes decrease and then shooting up when
> > > they go to zero.)  OK, I guess that's what you get if you just assume
> > > read-write contention is expensive and one write is slightly more
> > > expensive than one read.  But then why doesn't it behave the same way in
> > > the 56-thread case?)
> > > 
> > 
> > Yeah, I wondered about that too.
> 
> I was also forgetting that these are percentage increases.
> 
> For the future something that gave just the before and after numbers
> side-by-side might be easier to think about?
> 

Alas, that's what I can't release here. One of the perils of working at
a secretive startup. The part I can talk about is the fio job he was
using to test it:

"It was a fio 70/30 r/w random mix, where every thread was on a
 separate file."

...and this about the server hardware:

"On the server side it was Dual 2.6GHz Ivy-bridge 8-core w/ hyper
 threading enabled w/ 128GB RAM"

Unfortunately, I can't tell much about the underlying storage on the
server, other than that it's quite fast.

> > There is some virtualization in use on the clients here (and it's
> > vmware too), so I have to wonder if there's some variance in the
> > numbers due to weirdo virt behaviors or something.
> > 
> > The good news is that the overall trend pretty clearly shows a
> > performance increase.
> 
> Yep, sure.
> 
> > 
> > As always, benchmark results point out the need for more benchmarks.
> > 
> > -- 
> > Jeff Layton <jlayton@primarydata.com>


-- 
Jeff Layton <jlayton@primarydata.com>
