Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:37168 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3A3XmA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 18:42:00 -0500
Received: by mail-ia0-f174.google.com with SMTP id o25so3185053iad.33
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 15:42:00 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 0/9] Dynamically load GSS pseudoflavors by OID
To: linux-nfs@vger.kernel.org
Date: Wed, 30 Jan 2013 18:41:57 -0500
Message-ID: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Currently the RPC client is able to dynamically load GSS security
flavor support by name or pseudoflavor number, but not by
[OID, qop, service] tuple.  Such a tuple can be provided by an NFSv4
server in a SECINFO reply, for example.

This means that if an NFSv4 server lists a tuple for, say, krb5p, in
a SECINFO reply, our client will pretend it doesn't support krb5p if
the rpc-auth-gss-krb5 module is available on the system but does not
happen to be loaded at that moment.

This series implements support for loading the correct GSS
pseudoflavor module before searching by GSS tuple.  This version
needs testing, which I'll get to first thing tomorrow, but I've
already tested earlier versions of these patches with success.

Thanks to reviewers of v1.  Changes since v1:

  1.  Simplify function and method names
  2.  Add an equivalent server-side interface
  3.  Improve automatic loading of the auth_rpcgss module
  4.  nfs_find_best_sec() also verifies non-GSS flavors against
      RPC client's list of registered flavors
  5.  Search for (qop, svc) pair without adding a new function
  6.  Clean up GSS mech switch
  7.  Remove dprintk() calls
  8.  Improve patch descriptions
  9.  Numerous small improvements and fixes

---

Chuck Lever (9):
      SUNRPC: Remove EXPORT_SYMBOL_GPL() from GSS mech switch
      SUNRPC: Make gss_mech_get() static
      SUNRPC: Refactor nfsd4_do_encode_secinfo()
      SUNRPC: Consider qop when looking up pseudoflavors
      SUNRPC: Load GSS kernel module by OID
      SUNRPC: Introduce rpcauth_get_pseudoflavor()
      SUNRPC: Define rpcsec_gss_info structure
      NFS: Remove unneeded forward declaration
      SUNRPC: Missing module alias for auth_rpcgss.ko


 fs/nfs/nfs4namespace.c                |   43 +++++++-----
 fs/nfs/nfs4xdr.c                      |   20 +++---
 fs/nfsd/nfs4xdr.c                     |   43 ++++++------
 include/linux/nfs_xdr.h               |   24 +------
 include/linux/sunrpc/auth.h           |    6 ++
 include/linux/sunrpc/gss_api.h        |   29 ++++++--
 net/sunrpc/Kconfig                    |    1 
 net/sunrpc/auth.c                     |   68 +++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    3 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    6 +-
 net/sunrpc/auth_gss/gss_mech_switch.c |  117 +++++++++++++++++++++++++--------
 net/sunrpc/auth_gss/svcauth_gss.c     |    4 +
 12 files changed, 257 insertions(+), 107 deletions(-)

-- 
Chuck Lever
