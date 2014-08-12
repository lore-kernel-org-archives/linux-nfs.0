Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754731AbaHLUEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 16:04:47 -0400
Date: Tue, 12 Aug 2014 16:04:46 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 04/11] SUNRPC: Do not override wspace tests in
 svc_handle_xprt
Message-ID: <20140812200446.GD25914@fieldses.org>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <20140812191643.GB25914@fieldses.org>
 <CAHQdGtTL9nd_GJyV7Fn9F+YMAHk4EGU5=6OXCke35ymr7jzrrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTL9nd_GJyV7Fn9F+YMAHk4EGU5=6OXCke35ymr7jzrrA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2014 at 03:31:43PM -0400, Trond Myklebust wrote:
> On Tue, Aug 12, 2014 at 3:16 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > On Sun, Aug 03, 2014 at 01:03:06PM -0400, Trond Myklebust wrote:
> >> We already determined that there was enough wspace when we
> >> called svc_xprt_enqueue.
> >
> > So xpo_has_wspace may have returned true then, but I don't see what
> > guarantees it still would now.  Couldn't another server thread have also
> > run svc_recv() and the atomic_add(rqstp->rq_reserved,
> > &xprt->xpt_reserved) between the svc_xprt_enqueue call and now?
> 
> The point is that all this is just a heuristic: the TCP send window
> can collapse at any time. So rather than waste cycles doing multiple
> redundant tests that ultimately mean nothing when you call sendmsg(),
> do it once and be damned...

OK, makes sense.

--b.
