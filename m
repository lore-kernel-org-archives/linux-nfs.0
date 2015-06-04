Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:12626 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbbFDUGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 16:06:25 -0400
Date: Thu, 4 Jun 2015 22:06:22 +0200
From: Guillaume Morin <guillaume@morinfr.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Guillaume Morin <guillaume@morinfr.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Subject: Re: [BUG] nfs3 client stops retrying to connect
Message-ID: <20150604200621.GA10335@bender.morinfr.org>
References: <20150521012155.GA19680@bender.morinfr.org>
 <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 03 Jun 14:31, Chuck Lever wrote:
> > If somehow xs_close() is called before the callback
> > happens, I think it could leave XPRT_CONNECTING on forever though
> > (since xs_tcp_setup_socket is never called), see
> > https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/sunrpc/xprtsock.c?id=refs/tags/v3.14.43#n887
> > 
> > I am still have a few clients with the stuck mount so I could gather
> > more information if necessary.
> 
> A series of commits were merged into the v4.0 kernel, starting with commit 4dda9c8a5e34,
> that changed the TCP connect logic significantly. It would be helpful to know if the
> problem can be reproduced when your clients are running the v4.0 kernel.

Understood but I actually cannot reproduce it on 3.14 as well so I am
not hopeful I'll be able to try this.

This just happened during a kernel panic of our nfs server which stayed
down for a while, then only a dozen machines could not recover, the rest
was fine.  So it is definitely not that easy to trigger.

So far all my attempts to reproduce this have failed.  I tried mostly by
setting iptables to send RSTs back to the server randomly using iptables
and dropping syns pretty often. If you have any suggestions, that'd be
great

Do you have any thoughts about my impression that there could be race
between cancelling the callback in xs_close() that could leave
XPRT_CONNECTING on?

Thanks in advance

Guillaume.

-- 
Guillaume Morin <guillaume@morinfr.org>
