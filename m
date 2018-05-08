Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50958 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755438AbeEHRoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 May 2018 13:44:32 -0400
Date: Tue, 8 May 2018 13:44:31 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Trond Myklebust <trondmy@hammer.space>,
        "syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com"
        <syzbot+4b98281f2401ab849f4b@syzkaller.appspotmail.com>,
        "syzkaller-bugs@googlegroups.com" <syzkaller-bugs@googlegroups.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: general protection fault in encode_rpcb_string
Message-ID: <20180508174431.GE6151@fieldses.org>
References: <f4f5e80803d08f47b9056a0366dd@google.com>
 <20180417213308.GC18217@fieldses.org>
 <1524002074.63751.5.camel@hammer.space>
 <20180508161529.GD6151@fieldses.org>
 <4B24FAE4-C7E8-4D01-9808-B8F4E9E59D64@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B24FAE4-C7E8-4D01-9808-B8F4E9E59D64@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 08, 2018 at 12:34:48PM -0400, Chuck Lever wrote:
> 
> 
> > On May 8, 2018, at 12:15 PM, bfields@fieldses.org wrote:
> > 
> > On Tue, Apr 17, 2018 at 09:54:36PM +0000, Trond Myklebust wrote:
> >> Yes, and we can probably convert it, and the other GFP_ATOMIC
> >> allocations in the rpcbind client to use GFP_NOFS in order to improve
> >> reliability.
> > 
> > Chuck, I think the GFP_ATOMIC is unnecessary here as well?
> > 
> > --b.
> > 
> > diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> > index e8adad33d0bb..de90c6c90cde 100644
> > --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> > +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> > @@ -228,7 +228,7 @@ rpcrdma_convert_iovs(struct rpcrdma_xprt *r_xprt, struct xdr_buf *xdrbuf,
> > 			/* XXX: Certain upper layer operations do
> > 			 *	not provide receive buffer pages.
> > 			 */
> > -			*ppages = alloc_page(GFP_ATOMIC);
> > +			*ppages = alloc_page(GFP_NOFS);
> > 			if (!*ppages)
> > 				return -EAGAIN;
> > 		}
> 
> This code can't sleep, as I understand it. Caller is holding
> the transport write lock. This logic was copied from
> xdr_partial_copy_from_skb, which uses GFP_ATOMIC.

OK.

> Recall that this is here because of GETACL. As I've stated in
> the past, the correct solution is to ensure that these pages
> are provided in every case by the upper layer, making this
> alloc_page call site unnecessary.

Got it.

--b.
