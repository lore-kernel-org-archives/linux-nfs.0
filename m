Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41092 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755830Ab0IWSyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 14:54:37 -0400
Message-ID: <4C9BA266.1040102@suse.de>
Date: Fri, 24 Sep 2010 00:24:30 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: steved@redhat.com
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@netapp.com
Subject: [PATCH] nfs(5): document new local_lock option
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kernel 2.6.37 would most likely add a new mount option: local_lock.
Document the new option in the nfs(5) man page.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 utils/mount/nfs.man |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 55d4b55..d2a4c5f 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -717,6 +717,50 @@ If this option is not specified, the NFS client uses READDIRPLUS requests
 on NFS version 3 mounts to read small directories.
 Some applications perform better if the client uses only READDIR requests
 for all directories.
+.TP 1.5i
+.BR local_lock= mechanism
+Specifies whether to use local locking for any or both of the flock and the
+POSIX locking mechanisms.
+.I mechanism
+can be one of
+.BR all ,
+.BR flock ,
+.BR posix ,
+or
+.BR none .
+This option is supported in kernels 2.6.37 and later.
+.IP
+The Linux NFS client provides a way to make locks local. This means, the
+applications can lock files, but such locks provide exclusion only against
+other applications running on the same client. Remote applications are not
+affected by these locks.
+.IP
+If this option is not specified, or if
+.B none
+is specified, the client assumes that the locks are not local.
+.IP
+If
+.BR all
+is specified, the client assumes that both flock and POSIX locks are local.
+.IP
+If
+.BR flock
+is specified, the client assumes that only flock locks are local and uses
+NLM sideband protocol to lock files when POSIX locks are used.
+.IP
+If
+.BR posix
+is specified, the client assumes that POSIX locks are local and uses NLM
+sideband protocol to lock files when flock locks are used.
+.IP
+To support legacy flock behavior similar to that of NFS clients < 2.6.12, use
+'local_lock=flock'. This option is required when exporting NFS mounts via
+Samba as Samba maps Windows share mode locks as flock. Since NFS clients >
+2.6.12 implement flock by emulating POSIX locks, this will result in
+conflicting locks.
+.IP
+NOTE: When used together, the 'local_lock' mount option will be overridden
+by 'nolock'/'lock' mount option.
 .SS "Options for version 4 only"
 Use these options, along with the options in the first subsection above,
 for NFSv4 only. They will be ignored with older versions.
