Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33383 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbcADDPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jan 2016 22:15:35 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so158755852pfb.0
        for <linux-nfs@vger.kernel.org>; Sun, 03 Jan 2016 19:15:35 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsd: Fix nfsd leaks sunrpc module references
To: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
References: <20150911104517.GA4947@stefanha-thinkpad.home>
Cc: Stefan Hajnoczi <stefanha@redhat.com>, kinglongmee@gmail.com,
        skinsbursky@parallels.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <5689E3C9.1010708@gmail.com>
Date: Mon, 4 Jan 2016 11:15:21 +0800
MIME-Version: 1.0
In-Reply-To: <20150911104517.GA4947@stefanha-thinkpad.home>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stefan Hajnoczi reports,
nfsd leaks 3 references to the sunrpc module here:

  # echo -n "asdf 1234" >/proc/fs/nfsd/portlist
  bash: echo: write error: Protocol not supported

Now stop nfsd and try unloading the kernel modules:

  # systemctl stop nfs-server
  # systemctl stop nfs
  # systemctl stop proc-fs-nfsd.mount
  # systemctl stop var-lib-nfs-rpc_pipefs.mount
  # rmmod nfsd
  # rmmod nfs_acl
  # rmmod lockd
  # rmmod auth_rpcgss
  # rmmod sunrpc
  rmmod: ERROR: Module sunrpc is in use
  # lsmod | grep rpc
  sunrpc                315392  3

It is caused by nfsd don't cleanup rpcb program for nfsd
when destroying svc service after creating xprt fail.

Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfssvc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ad4e237..543de5f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -314,14 +314,13 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 	 * write_ports can create the server without actually starting
 	 * any threads--if we get shut down before any threads are
 	 * started, then nfsd_last_thread will be run before any of this
-	 * other initialization has been done.
+	 * other initialization has been done except the rpcb information.
 	 */
+	svc_rpcb_cleanup(serv, net);
 	if (!nn->nfsd_net_up)
 		return;
-	nfsd_shutdown_net(net);
-
-	svc_rpcb_cleanup(serv, net);
 
+	nfsd_shutdown_net(net);
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
 			    "cache\n");
 	nfsd_export_flush(net);
-- 
2.5.0

