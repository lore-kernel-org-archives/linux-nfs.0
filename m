Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49375 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314AbaLIRFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 12:05:50 -0500
Date: Tue, 9 Dec 2014 12:05:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Chris Worley <chris.worley@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] sunrpc: add a rcu_head to svc_rqst and use kfree_rcu
 to free it
Message-ID: <20141209170549.GI20526@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <1416597571-4265-2-git-send-email-jlayton@primarydata.com>
 <20141201224407.GD30749@fieldses.org>
 <20141201180533.7c8a7587@tlielax.poochiereds.net>
 <CAHQdGtS=deh6zZXGv132PKzLROMXQBA83zV=dw_0RLTAqksuiQ@mail.gmail.com>
 <20141201192954.17b89214@tlielax.poochiereds.net>
 <CAABAsM7=i7Hm2O+RVuYsh6kY=3GVKHcdJ0MwNmVUwFOMt2A8_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM7=i7Hm2O+RVuYsh6kY=3GVKHcdJ0MwNmVUwFOMt2A8_A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 01, 2014 at 07:52:20PM -0500, Trond Myklebust wrote:
> On Mon, Dec 1, 2014 at 7:29 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > There are two atomicity "concerns" here...
> >
> > The main thing is to ensure that we use set_bit or test_and_set_bit to
> > set the flag. What we *can't* use is __set_bit which is non-atomic
> > or we'd end up hitting the exact problem you're talking about (possibly
> > changing an unrelated flag in the field that happened to flip at nearly
> > the same time).
> >
> > What's not necessary here is to use test_and_set_bit since all of this
> > is done under spinlock anyway. In principle, we could do a test_bit and
> > then follow that up with a set_bit if it's clear. But, I don't think
> > that really buys us much, and tend to find the test_and_set_bit to be
> > clearer when reading the code.
> 
> Fair enough. I too would be surprised if you could actually measure
> that performance difference in the thread kill code.

Yeah, please don't bother, I was just thinking aloud here.

--b.
