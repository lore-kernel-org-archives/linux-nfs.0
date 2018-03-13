Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr50134.outbound.protection.outlook.com ([40.107.5.134]:60236
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932831AbeCMKtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Mar 2018 06:49:13 -0400
Subject: [PATCH net-next nfs 0/6] Converting pernet_operations (part #7)
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: davem@davemloft.net, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, dhowells@redhat.com, ktkhai@virtuozzo.com,
        keescook@chromium.org, dwindsor@gmail.com, ishkamiel@gmail.com,
        elena.reshetova@intel.com, linux-nfs@vger.kernel.org,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org
Date: Tue, 13 Mar 2018 13:49:05 +0300
Message-ID: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

this series continues to review and to convert pernet_operations
to make them possible to be executed in parallel for several
net namespaces in the same time. There are nfs pernet_operations
in this series. All of them look similar each other, they mostly
create and destroy caches with small exceptions.

Also, there is rxrpc_net_ops, which is used in AFS.

Thanks,
Kirill
---

Kirill Tkhai (6):
      net: Convert rpcsec_gss_net_ops
      net: Convert sunrpc_net_ops
      net: Convert nfsd_net_ops
      net: Convert nfs4_dns_resolver_ops
      net: Convert nfs4blocklayout_net_ops
      net: Convert rxrpc_net_ops


 fs/nfs/blocklayout/rpc_pipefs.c |    1 +
 fs/nfs/dns_resolve.c            |    1 +
 fs/nfsd/nfsctl.c                |    1 +
 net/rxrpc/net_ns.c              |    1 +
 net/sunrpc/auth_gss/auth_gss.c  |    1 +
 net/sunrpc/sunrpc_syms.c        |    1 +
 6 files changed, 6 insertions(+)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
