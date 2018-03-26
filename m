Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55392 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751739AbeCZSg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Mar 2018 14:36:59 -0400
Date: Mon, 26 Mar 2018 14:36:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, davem@davemloft.net,
        trond.myklebust@primarydata.com, jlayton@kernel.org,
        dhowells@redhat.com, keescook@chromium.org, dwindsor@gmail.com,
        ishkamiel@gmail.com, elena.reshetova@intel.com,
        linux-nfs@vger.kernel.org, linux-afs@lists.infradead.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH net-next nfs 1/6] net: Convert rpcsec_gss_net_ops
Message-ID: <20180326183659.GA25744@fieldses.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <152093815494.8636.6607369744413088370.stgit@localhost.localdomain>
 <28c32fa9-17e1-0399-d7bf-760441128cf8@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <28c32fa9-17e1-0399-d7bf-760441128cf8@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 23, 2018 at 02:53:34PM -0400, Anna Schumaker wrote:
> 
> 
> On 03/13/2018 06:49 AM, Kirill Tkhai wrote:
> > These pernet_operations initialize and destroy sunrpc_net_id refered
> > per-net items. Only used global list is cache_list, and accesses
> > already serialized.
> > 
> > sunrpc_destroy_cache_detail() check for list_empty() without
> > cache_list_lock, but when it's called from
> > unregister_pernet_subsys(), there can't be callers in parallel, so
> > we won't miss list_empty() in this case.
> > 
> > Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> It might make sense to take these and the other NFS patches through
> the net tree, since the pernet_operations don't yet have the async
> field in my tree (and I therefore can't compile once these are
> applied).

Ditto for the nfsd patch, so, for what it's worth:

	Acked-by: J. Bruce Fields <bfields@redhat.com>

for that patch.--b.

--b.
