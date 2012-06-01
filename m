Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:2074 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759480Ab2FALUJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 07:20:09 -0400
Subject: [PATCH 0/2] NFS: callback shutdown panic fix 
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Jun 2012 15:17:34 +0400
Message-ID: <20120601111619.7846.95457.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set is the back-port of "SUNRPC: separate per-net data creation
from service" patch set and "NFS: hard-code init_net for NFS callback
transports" patch for 3.5 kernel.

It fixes NULL pointer dereference in svc_destroy(), reported by Dave Jones in
"3.4. sunrpc oops during shutdown" e-mail.

The following series implements...

---

Stanislav Kinsbursky (2):
      SUNRPC: new svc_bind() routine introduced
      SUNRPC: move per-net operations from svc_destroy()


 fs/lockd/svc.c             |   33 +++++++++++++++++++++------------
 fs/nfs/callback.c          |   16 +++++++++++++---
 fs/nfsd/nfsctl.c           |   12 +++++++++---
 fs/nfsd/nfssvc.c           |   23 +++++++++++++++++++++++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/rpcb_clnt.c     |   12 +++++++-----
 net/sunrpc/svc.c           |   23 ++++++++++-------------
 7 files changed, 84 insertions(+), 36 deletions(-)
