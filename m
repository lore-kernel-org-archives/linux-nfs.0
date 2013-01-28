Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:46100 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab3A1UbY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:31:24 -0500
Received: by mail-ie0-f174.google.com with SMTP id k10so912921iea.5
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:31:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 0/5] Dynamically load security flavors by OID
To: linux-nfs@vger.kernel.org
Date: Mon, 28 Jan 2013 15:31:22 -0500
Message-ID: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Currently the RPC client is able to dynamically load GSS security
flavor support by name or pseudoflavor number, but not by
[OID, qop, service] tuple.  Such a tuple is provided by a server in
a SECINFO reply.

This means that if a server lists a tuple for, say, krb5p, in a
SECINFO reply, the client will pretend it doesn't support it if the
kernel module for krb5p is available on the system but does not
happen to be loaded at that moment.

This series implements support for loading the correct GSS module
before searching by GSS tuple.  The series has seen some successful
light testing, so it's time for wider review.  Suggestions about how
to test this series are welcome.

Trond, back when we discussed this change, there was also some
hand-waving about how to deal with WRONG_SEC on the pseudo-fs root.
Any thoughts or recollection about that?

I have 'But we have to worry about WRONG_SEC on the root.  "Fixed in
4.1, but fucking bug in 4.0.' and then 'For NFSv4.0 root FS, we can
use a fixed array of mandated flavors, and the new "try to autoload
pseudo flavor" API'.

Somehow that's going to have to be folded into the 4.0 trunking
detection logic.

---

Chuck Lever (5):
      SUNRPC: Consider qop when looking up pseudoflavors
      SUNRPC: Find kernel module by OID
      SUNRPC: Introduce rpcauth_lookup_gss_pseudoflavor()
      SUNRPC: Define rpcsec_gss_info structure
      NFS: Remove unneeded forward declaration


 fs/nfs/nfs4namespace.c                |   48 +++++++++++++++++------------
 fs/nfs/nfs4xdr.c                      |   20 +++++++-----
 include/linux/nfs_xdr.h               |   24 +++-----------
 include/linux/sunrpc/auth.h           |    4 ++
 include/linux/sunrpc/auth_gss.h       |    6 ----
 include/linux/sunrpc/gss_api.h        |   25 +++++++++++++--
 net/sunrpc/Kconfig                    |    1 +
 net/sunrpc/auth.c                     |   31 +++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c        |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 ++
 net/sunrpc/auth_gss/gss_mech_switch.c |   55 ++++++++++++++++++++++++++++++---
 11 files changed, 158 insertions(+), 61 deletions(-)

-- 
Chuck Lever
