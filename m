Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43926 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab3CPTyK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:54:10 -0400
Received: by mail-ie0-f182.google.com with SMTP id k14so5622993iea.41
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:54:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 00/15] Security flavor negotiation fixes
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Sat, 16 Mar 2013 15:54:07 -0400
Message-ID: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please consider these for 3.10.  With the exception of 15/15, similar
or the same patches have been posted here before.

The NFSv3 MNT changes we discussed at the pub will appear soon.

---

Chuck Lever (15):
      NFS: Use "krb5i" to establish NFSv4 state whenever possible
      NFS: Try AUTH_UNIX when PUTROOTFH gets NFS4ERR_WRONGSEC
      NFS: Use static list of security flavors during root FH lookup recovery
      NFS: Avoid PUTROOTFH when managing leases
      NFS: Clean up nfs4_proc_get_rootfh
      NFS: Handle missing rpc.gssd when looking up root FH
      SUNRPC: Remove EXPORT_SYMBOL_GPL() from GSS mech switch
      SUNRPC: Make gss_mech_get() static
      SUNRPC: Refactor nfsd4_do_encode_secinfo()
      SUNRPC: Consider qop when looking up pseudoflavors
      SUNRPC: Load GSS kernel module by OID
      SUNRPC: Introduce rpcauth_get_pseudoflavor()
      SUNRPC: Define rpcsec_gss_info structure
      NFS: Remove unneeded forward declaration
      SUNRPC: Missing module alias for auth_rpcgss.ko


 fs/nfs/nfs4client.c                   |    2 -
 fs/nfs/nfs4namespace.c                |   43 +++++++-----
 fs/nfs/nfs4proc.c                     |   92 ++++++++++++++++----------
 fs/nfs/nfs4state.c                    |   37 +---------
 fs/nfs/nfs4xdr.c                      |   39 ++++-------
 fs/nfsd/nfs4xdr.c                     |   24 +++----
 include/linux/nfs_xdr.h               |   24 +------
 include/linux/sunrpc/auth.h           |    9 ++
 include/linux/sunrpc/gss_api.h        |   30 ++++++--
 net/sunrpc/Kconfig                    |    1 
 net/sunrpc/auth.c                     |   70 +++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    3 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    6 +-
 net/sunrpc/auth_gss/gss_mech_switch.c |  119 +++++++++++++++++++++++++--------
 net/sunrpc/auth_gss/svcauth_gss.c     |    4 +
 15 files changed, 319 insertions(+), 184 deletions(-)

-- 
Chuck Lever
