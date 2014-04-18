Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([74.45.170.26]:53682 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbaDRU05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 16:26:57 -0400
Message-ID: <53518350.8010605@canonical.com>
Date: Fri, 18 Apr 2014 13:56:00 -0600
From: Tim Gardner <tim.gardner@canonical.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH net-next] xprtrdma: rpcrdma_register_default_external:
 Silence frame size warning
References: <1397850625-44074-1-git-send-email-tim.gardner@canonical.com> <CAHQdGtQyntscf5kwgWW-v0hWvdT0djKHhibhKNRtwGrcPu-e-Q@mail.gmail.com>
In-Reply-To: <CAHQdGtQyntscf5kwgWW-v0hWvdT0djKHhibhKNRtwGrcPu-e-Q@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/18/2014 01:52 PM, Trond Myklebust wrote:
>
> On Fri, Apr 18, 2014 at 3:50 PM, Tim Gardner <tim.gardner@canonical.com
> <mailto:tim.gardner@canonical.com>> wrote:
>
>     net/sunrpc/xprtrdma/verbs.c: In function
>     'rpcrdma_register_default_external':
>     net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1048
>     bytes is larger than 1024 bytes [-Wframe-larger-than=]
>
>     gcc version 4.8.2, x86_64-linux-gnu
>
>     Cc: Trond Myklebust <trond.myklebust@primarydata.com
>     <mailto:trond.myklebust@primarydata.com>>
>     Cc: "J. Bruce Fields" <bfields@fieldses.org
>     <mailto:bfields@fieldses.org>>
>     Cc: "David S. Miller" <davem@davemloft.net <mailto:davem@davemloft.net>>
>     Signed-off-by: Tim Gardner <tim.gardner@canonical.com
>     <mailto:tim.gardner@canonical.com>>
>     ---
>       net/sunrpc/xprtrdma/verbs.c |    8 +++++++-
>       1 file changed, 7 insertions(+), 1 deletion(-)
>
>     diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>     index 93726560..8130349 100644
>     --- a/net/sunrpc/xprtrdma/verbs.c
>     +++ b/net/sunrpc/xprtrdma/verbs.c
>     @@ -1736,9 +1736,13 @@ rpcrdma_register_default_external(struct
>     rpcrdma_mr_seg *seg,
>              int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>                                        IB_ACCESS_REMOTE_READ);
>              struct rpcrdma_mr_seg *seg1 = seg;
>     -       struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>     +       struct ib_phys_buf *ipb;
>              int len, i, rc = 0;
>
>     +       ipb = kmalloc(sizeof(*ipb) * RPCRDMA_MAX_DATA_SEGS, GFP_ATOMIC);
>     +       if (!ipb)
>     +               return -ENOMEM;
>     +
>              if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>                      *nsegs = RPCRDMA_MAX_DATA_SEGS;
>              for (len = 0, i = 0; i < *nsegs;) {
>     @@ -1770,6 +1774,8 @@ rpcrdma_register_default_external(struct
>     rpcrdma_mr_seg *seg,
>                      seg1->mr_len = len;
>              }
>              *nsegs = i;
>     +
>     +       kfree(ipb);
>              return rc;
>       }
>
>     --
>     1.7.9.5
>
> What has this got to do with net-next? It is RPC related...
>
> --
>
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com <mailto:trond.myklebust@primarydata.com>
>

I guess I naively thought that anything under the net directory went 
through Dave's tree.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
