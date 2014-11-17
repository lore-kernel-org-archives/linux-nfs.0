Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:43004 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbaKQV6M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 16:58:12 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so18716203qcw.34
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 13:58:11 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] lockd/sunrpc: eliminate some pointless macro indirection
Date: Mon, 17 Nov 2014 16:58:02 -0500
Message-Id: <1416261485-24686-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have a number of legacy macros in the sunrpc code, as well
as a smaller number in lockd that are used to indicate whether debugging
support is compiled in or not.

This hash always seemed like pointless indirection as those symbols
always reflect the value of a CONFIG_* value. This patchset just removes
those macros in favor of their CONFIG_* equivalents.

Jeff Layton (3):
  lockd: eliminate LOCKD_DEBUG
  sunrpc: eliminate RPC_DEBUG
  sunrpc: eliminate RPC_TRACEPOINTS

 fs/lockd/svclock.c                      |  2 +-
 include/linux/lockd/debug.h             |  6 +-----
 include/linux/sunrpc/auth.h             |  2 +-
 include/linux/sunrpc/debug.h            | 18 +++---------------
 include/linux/sunrpc/sched.h            |  8 ++++----
 include/uapi/linux/nfsd/debug.h         |  2 +-
 net/sunrpc/auth.c                       |  4 ++--
 net/sunrpc/auth_generic.c               |  2 +-
 net/sunrpc/auth_gss/auth_gss.c          |  2 +-
 net/sunrpc/auth_gss/gss_generic_token.c |  2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c   |  2 +-
 net/sunrpc/auth_gss/gss_krb5_keys.c     |  2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c     |  2 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c     |  2 +-
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |  2 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c   |  2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c     |  2 +-
 net/sunrpc/auth_gss/gss_mech_switch.c   |  2 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h       |  2 +-
 net/sunrpc/auth_gss/svcauth_gss.c       |  2 +-
 net/sunrpc/auth_null.c                  |  4 ++--
 net/sunrpc/auth_unix.c                  |  2 +-
 net/sunrpc/backchannel_rqst.c           |  2 +-
 net/sunrpc/clnt.c                       |  6 +++---
 net/sunrpc/rpcb_clnt.c                  |  2 +-
 net/sunrpc/sched.c                      |  4 ++--
 net/sunrpc/sunrpc_syms.c                |  4 ++--
 net/sunrpc/svc.c                        |  2 +-
 net/sunrpc/sysctl.c                     |  2 +-
 net/sunrpc/xprt.c                       |  2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c          |  4 ++--
 net/sunrpc/xprtrdma/transport.c         |  8 ++++----
 net/sunrpc/xprtrdma/verbs.c             |  8 ++++----
 net/sunrpc/xprtsock.c                   |  8 ++++----
 34 files changed, 55 insertions(+), 71 deletions(-)

-- 
2.1.0

