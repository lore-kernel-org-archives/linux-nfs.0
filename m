Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ia0-f169.google.com ([209.85.210.169]:49308 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab3BFX37 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 18:29:59 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so2366589iaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2013 15:29:59 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 0/4] Improving WRONGSEC recovery during lookup_root
To: linux-nfs@vger.kernel.org
Date: Wed, 06 Feb 2013 18:29:55 -0500
Message-ID: <20130206230045.1535.48770.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been playing with some improvements to how the Linux NFS client
behaves when a server requires a stronger security flavor than
AUTH_UNIX to access its pseudo-fs.

AUTH_UNIX is the default flavor our client uses when no security
flavor preference was specified on the mount command.  The client
has to be smart enough to negotiate the security flavor when the
server may require something a little stronger.

Typically servers take a union of security flavors on all their
current real shares and use that set as the security flavors
required for the pseudo-fs.  If a server's real shares are exported
with only various flavors of Kerberos, for instance, then the
server's pseudo-fs will not allow AUTH_UNIX access, though the
server might still allow a SETCLIENTID operation with AUTH_UNIX in
this case.

This work is also relevant if we want to consider using an
integrity-protecting security flavor for lease management operations
(such as SETCLIENTID and RENEW) while allowing other flavors for
accessing data or the pseudo-fs.

Version 1 of this series is the result.  I've done some testing with
a Linux NFS server configured to require a flavor of Kerberos to
access its pseudo-fs.  I also tried some testing with a Solaris NFS
server.

Bryan, I copied you because you originally wrote the find_root_sec
code: any comments, review, or testing is appreciated.

---

Chuck Lever (4):
      NFS: Use static list of security flavors during root FH lookup recovery
      NFS: Avoid PUTROOTFH when managing leases
      NFS: Clean up nfs4_proc_get_rootfh
      NFS: Handle missing rpc.gssd when looking up root FH


 fs/nfs/nfs4proc.c |  134 ++++++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4xdr.c  |   18 +------
 2 files changed, 104 insertions(+), 48 deletions(-)

-- 
Chuck Lever
