Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbeCMP0F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:26:05 -0400
Date: Tue, 13 Mar 2018 11:26:03 -0400 (EDT)
Message-Id: <20180313.112603.536998224376970475.davem@davemloft.net>
To: ktkhai@virtuozzo.com
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@kernel.org, dhowells@redhat.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Subject: Re: [PATCH net-next nfs 0/6] Converting pernet_operations (part #7)
From: David Miller <davem@davemloft.net>
In-Reply-To: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 13 Mar 2018 13:49:05 +0300

> Hi,
> 
> this series continues to review and to convert pernet_operations
> to make them possible to be executed in parallel for several
> net namespaces in the same time. There are nfs pernet_operations
> in this series. All of them look similar each other, they mostly
> create and destroy caches with small exceptions.
> 
> Also, there is rxrpc_net_ops, which is used in AFS.

I'll let the various maintainers pick these up instead of passing
them via the net-next tree.
