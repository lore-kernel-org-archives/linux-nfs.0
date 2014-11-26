Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:50926 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaKZTow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 14:44:52 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so2374371qab.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 11:44:51 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/5] sunrpc: add some debugfs files for dumping task and xprt info
Date: Wed, 26 Nov 2014 14:44:39 -0500
Message-Id: <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
References: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- add a patch that creates and populates a rpc_xprt directory
- take reference on rpc_clnt when "tasks" file is opened
- minor cleanups

v2:
- add a whole new directory hierarchy instead of a single
  client_tasks file
- respin patches to remove LOCKD_DEBUG/RPC_DEBUG/RPC_TRACEPOINTS defines

Ok, here is the latest (and hopefully last!) respin of the patches to
add some debugfs files to dump info about rpc_clnt and rpc_xprt
objects.

This set ensures that references are properly acquired so that the
objects don't disappear while we're working on them. I've also included
the patches to eliminate the RPC_DEBUG defines too as they should be
merged first to prevent conflicts.

Trond, can you consider these for v3.19?

Thanks!

Jeff Layton (5):
  lockd: eliminate LOCKD_DEBUG
  sunrpc: eliminate RPC_DEBUG
  sunrpc: eliminate RPC_TRACEPOINTS
  sunrpc: add debugfs file for displaying client rpc_task queue
  sunrpc: add a debugfs rpc_xprt directory with an info file in it

 fs/lockd/svclock.c                      |   2 +-
 include/linux/lockd/debug.h             |   6 +-
 include/linux/sunrpc/auth.h             |   2 +-
 include/linux/sunrpc/clnt.h             |   4 +
 include/linux/sunrpc/debug.h            |  64 +++++--
 include/linux/sunrpc/sched.h            |   8 +-
 include/linux/sunrpc/xprt.h             |   3 +
 include/uapi/linux/nfsd/debug.h         |   2 +-
 net/sunrpc/Kconfig                      |   1 +
 net/sunrpc/Makefile                     |   1 +
 net/sunrpc/auth.c                       |   4 +-
 net/sunrpc/auth_generic.c               |   2 +-
 net/sunrpc/auth_gss/auth_gss.c          |   2 +-
 net/sunrpc/auth_gss/gss_generic_token.c |   2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_keys.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c     |   2 +-
 net/sunrpc/auth_gss/gss_mech_switch.c   |   2 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h       |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c       |   2 +-
 net/sunrpc/auth_null.c                  |   4 +-
 net/sunrpc/auth_unix.c                  |   2 +-
 net/sunrpc/backchannel_rqst.c           |   2 +-
 net/sunrpc/clnt.c                       |  16 +-
 net/sunrpc/debugfs.c                    | 292 ++++++++++++++++++++++++++++++++
 net/sunrpc/rpcb_clnt.c                  |   2 +-
 net/sunrpc/sched.c                      |   4 +-
 net/sunrpc/sunrpc_syms.c                |  12 +-
 net/sunrpc/svc.c                        |   2 +-
 net/sunrpc/sysctl.c                     |   2 +-
 net/sunrpc/xprt.c                       |  10 +-
 net/sunrpc/xprtrdma/rpc_rdma.c          |   4 +-
 net/sunrpc/xprtrdma/transport.c         |   8 +-
 net/sunrpc/xprtrdma/verbs.c             |   8 +-
 net/sunrpc/xprtsock.c                   |   8 +-
 39 files changed, 427 insertions(+), 72 deletions(-)
 create mode 100644 net/sunrpc/debugfs.c

-- 
2.1.0

