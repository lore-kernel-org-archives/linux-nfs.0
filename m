From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: null dereference on boot in nfs code
Date: Thu, 20 Aug 2009 19:21:20 -0400
Message-ID: <1250810480.6514.18.camel@heimdal.trondhjem.org>
References: <20090820223837.GF2451@fieldses.org>
	 <1250808688.6514.13.camel@heimdal.trondhjem.org>
	 <20090820225313.GG2451@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56264 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbZHTXVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 19:21:22 -0400
In-Reply-To: <20090820225313.GG2451@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 18:53 -0400, J. Bruce Fields wrote:
> On Thu, Aug 20, 2009 at 06:51:28PM -0400, Trond Myklebust wrote:
> Yes, everything's built in. (Also, confirmed with just the latest
> nfs-for-2.6.32.)
> 
> > If so, does it also happen when NFS (but not necessarily SUNRPC) is a
> > module?
> 
> Haven't tried that yet, I can look tomorrow.
> 
> > I'm wondering if the problem is that we need to ensure ordering of
> > init functions here...

Please try seeing if the following patch helps...

Cheers
  Trond

--------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Ensure that sunrpc gets initialised before nfs, lockd, etc...

We can oops if rpc_pipefs isn't properly initialised before we start to set
up objects that depend upon it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sunrpc_syms.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index adaa819..8cce921 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -69,5 +69,5 @@ cleanup_sunrpc(void)
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 MODULE_LICENSE("GPL");
-module_init(init_sunrpc);
+fs_initcall(init_sunrpc); /* Ensure we're initialised before nfs */
 module_exit(cleanup_sunrpc);


