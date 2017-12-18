Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48708 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935111AbdLRR1L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 12:27:11 -0500
Date: Mon, 18 Dec 2017 12:27:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mike Galbraith <efault@gmx.de>
Cc: lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
Message-ID: <20171218172711.GA12454@fieldses.org>
References: <1513610231.7998.13.camel@gmx.de>
 <1513611112.7113.1.camel@gmx.de>
 <20171218163559.GA11829@fieldses.org>
 <1513616405.7113.18.camel@gmx.de>
 <1513617456.7113.25.camel@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1513617456.7113.25.camel@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 18, 2017 at 06:17:36PM +0100, Mike Galbraith wrote:
> On Mon, 2017-12-18 at 18:00 +0100, Mike Galbraith wrote:
> > On Mon, 2017-12-18 at 11:35 -0500, J. Bruce Fields wrote:
> > > 
> > > Like I say, I don't really understand the issues here, so it's more a
> > > question than an objection....  (I don't know any reason a
> > > cond_resched() would be bad there.)
> > 
> > Think of it this way: what all can be queued up behind that kworker
> > that is hogging CPU for huge swaths of time?  It's not only userspace
> > that suffers.
> 
> Bah, I'm gonna sound like a damn Baptist preacher, but I gotta say,
> latency matters just as much to an enterprise NOPREEMPT kernel and its
> users as it does to a desktop kernel and its users.  For max
> throughput, you don't want to do work in _tiny_ quantum, because you
> then lose throughput due to massive cache trashing and scheduling
> overhead, but latency still does matter, and not just a little.

Right, what I don't understand is why kernels are still built without
preemption.  I'd naively assumed that was just a bandaid while we
weren't sure how much old kernel code might still depend on it for
correctness.  I'd forgotten about throughput/latency tradeoffs--but
couldn't those in theory be managed by runtime configuration of the
sceduler, or at least some smaller hammer than turning off preemption
entirely?

(But, again, just idle curiosity on my part, thanks for the answers.)

--b.
