Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41418 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698Ab1L2Rmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Dec 2011 12:42:38 -0500
Message-ID: <4EFCA668.6040107@parallels.com>
Date: Thu, 29 Dec 2011 21:42:00 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to
 named one
References: <4EFB330A.7070908@parallels.com> <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com> <4EFB521B.7060004@parallels.com> <406C7E87-0CCB-4034-8FD8-1602F7DCDBD6@oracle.com> <4EFC5391.7000601@parallels.com> <5E291DB3-7FB3-4108-B254-B59780C64346@oracle.com> <4EFC9189.5040605@parallels.com> <56767BFA-62B8-4E10-B9B3-4FD9EF278969@oracle.com>
In-Reply-To: <56767BFA-62B8-4E10-B9B3-4FD9EF278969@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.12.2011 20:23, Chuck Lever пишет:
>
> Do you have a patch so we can see just how ugly this might get?
>

Something like this (I've checked - it works properly).

From: Stanislav Kinsbursky <skinsbursky@parallels.com>


---
  fs/fs_struct.c        |    1 +
  net/sunrpc/xprtsock.c |   20 ++++++++++++++++++++
  2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 78b519c..0f984c3 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -36,6 +36,7 @@ void set_fs_root(struct fs_struct *fs, struct path *path)
         if (old_root.dentry)
                 path_put_longterm(&old_root);
  }
+EXPORT_SYMBOL_GPL(set_fs_root);

  /*
   * Replace the fs->{pwdmnt,pwd} with {mnt,dentry}. Put the old values.
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 610a74a..d22ef5b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -37,6 +37,7 @@
  #include <linux/sunrpc/svcsock.h>
  #include <linux/sunrpc/xprtsock.h>
  #include <linux/file.h>
+#include <linux/fs_struct.h>
  #ifdef CONFIG_SUNRPC_BACKCHANNEL
  #include <linux/sunrpc/bc_xprt.h>
  #endif
@@ -239,6 +240,8 @@ struct sock_xprt {
         void                    (*old_state_change)(struct sock *);
         void                    (*old_write_space)(struct sock *);
         void                    (*old_error_report)(struct sock *);
+
+       struct path             *root;
  };

  /*
@@ -848,6 +851,11 @@ static void xs_destroy(struct rpc_xprt *xprt)

         cancel_delayed_work_sync(&transport->connect_worker);

+       if (transport->root) {
+               path_put(transport->root);
+               kfree(transport->root);
+       }
+
         xs_close(xprt);
         xs_free_peer_addresses(xprt);
         xprt_free(xprt);
@@ -1881,6 +1889,7 @@ static void xs_local_setup_socket(struct work_struct *work)
         struct rpc_xprt *xprt = &transport->xprt;
         struct socket *sock;
         int status = -EIO;
+       struct path root;

         if (xprt->shutdown)
                 goto out;
@@ -1898,6 +1907,9 @@ static void xs_local_setup_socket(struct work_struct *work)
         dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
                         xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);

+       get_fs_root(current->fs, &root);
+       set_fs_root(current->fs, transport->root);
+
         status = xs_local_finish_connecting(xprt, sock);
         switch (status) {
         case 0:
@@ -1915,6 +1927,8 @@ static void xs_local_setup_socket(struct work_struct *work)
                                 xprt->address_strings[RPC_DISPLAY_ADDR]);
         }

+       set_fs_root(current->fs, &root);
+
  out:
         xprt_clear_connecting(xprt);
         xprt_wake_pending_tasks(xprt, status);
@@ -2577,6 +2591,12 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create 
*args)
                 INIT_DELAYED_WORK(&transport->connect_worker,
                                         xs_local_setup_socket);
                 xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
+
+               ret = ERR_PTR(-ENOMEM);
+               transport->root = kmalloc(GFP_KERNEL, sizeof(struct path));
+               if (transport->root)
+                       goto out_err;
+               get_fs_root(current->fs, transport->root);
                 break;
         default:
                 ret = ERR_PTR(-EAFNOSUPPORT);
