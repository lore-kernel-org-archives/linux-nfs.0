Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:62488 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935925AbdLRR1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Dec 2017 12:27:14 -0500
Message-ID: <1513618019.7113.27.camel@gmx.de>
Subject: Re: NFS: 82ms wakeup latency 4.14-rc4
From: Mike Galbraith <efault@gmx.de>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Date: Mon, 18 Dec 2017 18:26:59 +0100
In-Reply-To: <1513617866.4581.6.camel@primarydata.com>
References: <1513610231.7998.13.camel@gmx.de>
         <1513611112.7113.1.camel@gmx.de> <20171218163559.GA11829@fieldses.org>
         <1513616405.7113.18.camel@gmx.de> <1513617866.4581.6.camel@primarydata.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-12-18 at 17:24 +0000, Trond Myklebust wrote:
> On Mon, 2017-12-18 at 18:00 +0100, Mike Galbraith wrote:
> > On Mon, 2017-12-18 at 11:35 -0500, J. Bruce Fields wrote:
> > > 
> > > Like I say, I don't really understand the issues here, so it's more
> > > a
> > > question than an objection....  (I don't know any reason a
> > > cond_resched() would be bad there.)
> > 
> > Think of it this way: what all can be queued up behind that kworker
> > that is hogging CPU for huge swaths of time?  It's not only userspace
> > that suffers.
> > 
> 
> Any cond_sched() belongs in the loop in nfs_commit_release_pages()
> (where it can be mitigated) rather than in a function whose purpose is
> to free memory. There is no reason to call it from the writeback or
> readpages code.

(this is why bandaid didn't come equipped with changelog etc:)
