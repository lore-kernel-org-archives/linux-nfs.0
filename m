Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51698 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752348AbeCOOYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Mar 2018 10:24:53 -0400
Date: Thu, 15 Mar 2018 10:24:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, jlayton@kernel.org, dhowells@redhat.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Subject: Re: [PATCH net-next nfs 0/6] Converting pernet_operations (part #7)
Message-ID: <20180315142452.GA17336@fieldses.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <e9612f81-0306-6f87-2ad5-c79b848eafae@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e9612f81-0306-6f87-2ad5-c79b848eafae@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 15, 2018 at 04:32:30PM +0300, Kirill Tkhai wrote:
> Trond, Anna, Bruce, Jeff, David and other NFS and RXRPC people,
> could you please provide your vision on this patches?

Whoops, sorry, I haven't been paying attention.  Do you have a pointer
to documentation?  I'm unclear what the actual concurrency change
is--sounds like it becomes possible that e.g. multiple ->init methods
(from the same pernet_operations but for different namespaces) could run
in parallel?

Sounds likely to be safe, and I don't actually care too much who merges
them as they look very unlikely to conflict with anything pending.  But
unless anyone tells me otherwise I'll take the one nfsd_net_ops patch
and leave the rest to Anna or Trond.

--b.


> 
> Thanks,
> Kirill
> 
> On 13.03.2018 13:49, Kirill Tkhai wrote:
> > Hi,
> > 
> > this series continues to review and to convert pernet_operations
> > to make them possible to be executed in parallel for several
> > net namespaces in the same time. There are nfs pernet_operations
> > in this series. All of them look similar each other, they mostly
> > create and destroy caches with small exceptions.
> > 
> > Also, there is rxrpc_net_ops, which is used in AFS.
> > 
> > Thanks,
> > Kirill
> > ---
> > 
> > Kirill Tkhai (6):
> >       net: Convert rpcsec_gss_net_ops
> >       net: Convert sunrpc_net_ops
> >       net: Convert nfsd_net_ops
> >       net: Convert nfs4_dns_resolver_ops
> >       net: Convert nfs4blocklayout_net_ops
> >       net: Convert rxrpc_net_ops
> > 
> > 
> >  fs/nfs/blocklayout/rpc_pipefs.c |    1 +
> >  fs/nfs/dns_resolve.c            |    1 +
> >  fs/nfsd/nfsctl.c                |    1 +
> >  net/rxrpc/net_ns.c              |    1 +
> >  net/sunrpc/auth_gss/auth_gss.c  |    1 +
> >  net/sunrpc/sunrpc_syms.c        |    1 +
> >  6 files changed, 6 insertions(+)
> > 
> > --
> > Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> > 
