Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:40746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751330AbeCTQtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 12:49:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <152093820653.8636.15794912193976988473.stgit@localhost.localdomain>
References: <152093820653.8636.15794912193976988473.stgit@localhost.localdomain> <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: dhowells@redhat.com, davem@davemloft.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@kernel.org, keescook@chromium.org,
        dwindsor@gmail.com, ishkamiel@gmail.com, elena.reshetova@intel.com,
        linux-nfs@vger.kernel.org, linux-afs@lists.infradead.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH net-next nfs 6/6] net: Convert rxrpc_net_ops
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 20 Mar 2018 16:49:49 +0000
Message-ID: <4736.1521564589@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> These pernet_operations modifies rxrpc_net_id-pointed
> per-net entities. There is external link to AF_RXRPC
> in fs/afs/Kconfig, but it seems there is no other
> pernet_operations interested in that per-net entities.

The fs/afs/ namespacing stuff isn't active yet as I'm trying to decide on how
to deal with the DNS cache which also needs namespacing.

> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

DaveM: Can you take this into net-next and add:

Acked-by: David Howells <dhowells@redhat.com>
