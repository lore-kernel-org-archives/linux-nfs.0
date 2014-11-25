Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:40555 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaKYTBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 14:01:09 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so932527qcx.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 11:01:09 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] sunrpc:  add debugfs file for displaying client rpc_task queue
Date: Tue, 25 Nov 2014 14:00:56 -0500
Message-Id: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1414520695-1701-1-git-send-email-jlayton@primarydata.com>
References: <1414520695-1701-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of this patch that I sent a few weeks ago:

    sunrpc: add debugfs file for displaying client rpc_task queue

...to address Trond's concerns about how to lay out this directory.

I've also included a respin of the patches to eliminate the unneeded
#define redirection in the sunrpc debugging code. I had originally based
those patches on top of the debugfs patch, so if we drop that patch
there are merge conflicts with these.

In this set, I've reversed the order so if there are any more respins
needed on the debugfs work, I shouldn't need to resend the whole set.

Jeff Layton (4):
  lockd: eliminate LOCKD_DEBUG
  sunrpc: eliminate RPC_DEBUG
  sunrpc: eliminate RPC_TRACEPOINTS
  sunrpc: add debugfs file for displaying client rpc_task queue

 fs/lockd/svclock.c                      |   2 +-
 include/linux/lockd/debug.h             |   6 +-
 include/linux/sunrpc/auth.h             |   2 +-
 include/linux/sunrpc/clnt.h             |   4 +
 include/linux/sunrpc/debug.h            |  49 ++++++---
 include/linux/sunrpc/sched.h            |   8 +-
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
 net/sunrpc/clnt.c                       |  15 ++-
 net/sunrpc/debugfs.c                    | 173 ++++++++++++++++++++++++++++++++
 net/sunrpc/rpcb_clnt.c                  |   2 +-
 net/sunrpc/sched.c                      |   4 +-
 net/sunrpc/sunrpc_syms.c                |  12 ++-
 net/sunrpc/svc.c                        |   2 +-
 net/sunrpc/sysctl.c                     |   2 +-
 net/sunrpc/xprt.c                       |   2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c          |   4 +-
 net/sunrpc/xprtrdma/transport.c         |   8 +-
 net/sunrpc/xprtrdma/verbs.c             |   8 +-
 net/sunrpc/xprtsock.c                   |   8 +-
 38 files changed, 281 insertions(+), 72 deletions(-)
 create mode 100644 net/sunrpc/debugfs.c

-- 
2.1.0

