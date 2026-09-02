Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 354664457CE
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 13:36:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788356212; cv=none; b=VFlosAdOPKh6D+WZjxfzE+oGmTvNzQyLX9+V5qdsKFZltKoXuWlIPLYNjAR6jIMMGamOA1UveN5qUOcQMj9Z+FydaqRHcWlS7EWDzWU28Uj5hSLaKAWobDkw0en3gaRlQpEhtfjQ6aHk/vFfJ5JVv0fVui/+m/Q6ItltkOtcuAY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788356212; c=relaxed/simple;
	bh=gYAVTKDud6LLnOZ8fAe1CjQURiCz6YwsKuLYw8E9bVE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DWvF5hZMd7IP2Rq+YsmemRv660zjU/EA4P09rq1ErC9le29ceGSYlFX/tNrO90V/X8WnZgQuhq5pNw4pkKinMDDKIs6YCAE1Oi39YT+ki8dDSSf4bkhQEkFuACbfulfMqswjEDYLNb14sddaPYYeS+ysqaGzzKGJ47frdcVnNhU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=IXPlAWB9; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=Vu1WxRAv; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="IXPlAWB9";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="Vu1WxRAv"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 706E821D21;
	Wed,  2 Sep 2026 13:36:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1788356203; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=/NpE0gk3sU6wJynwh6MeYVi8FPWDm2m0yoQr8xjbT8o=;
	b=IXPlAWB9BvAP07ZKc7rXL7B6/QdiR7tBQRHsbFXua+wsRgN+AhKTE2tQhMiwGM+k5+jIIS
	tQqi5OwtPOtOIxjllghJJDBCNblpoDhK4h1GCbnhBHVisTF67WqT2z7me1SnsSwrZH94Ms
	LqCrBACSK0hFKyN0YZCKUzH5K8EBXwY=
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.com header.s=susede1 header.b=Vu1WxRAv
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1788356199; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
	bh=/NpE0gk3sU6wJynwh6MeYVi8FPWDm2m0yoQr8xjbT8o=;
	b=Vu1WxRAve40MjpblCp2MLd128ps5oB2imq5rZ1hYV4CB0d1oanIo+6oXQscWg0CxSBzbYy
	BBOc90cRqrEs2TB9b7+5WhP7QgZrhWoROcjIGxtbeCkT8gRfgp3x4LSY+JkU8W08Ffv05k
	9ckJDljuG3lBn1AuSPlle0IvSo3iC1M=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 5FF0C13736;
	Wed,  2 Sep 2026 13:36:37 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id OKV4E2UmmGrpXwAAD6G6ig
	(envelope-from <antonio.feijoo@suse.com>); Wed, 02 Sep 2026 13:36:37 +0000
From: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
To: linux-nfs@vger.kernel.org
Cc: Mike Snitzer <snitzer@kernel.org>,
	Anna Schumaker <anna.schumaker@hammerspace.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
Subject: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
Date: Wed,  2 Sep 2026 15:35:54 +0200
Message-ID: <20260902133554.28863-1-antonio.feijoo@suse.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Spam-Score: -3.01
X-Rspamd-Queue-Id: 706E821D21
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-3.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_CONTAINS_FROM(1.00)[];
	R_MISSING_CHARSET(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.com:s=susede1];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:dkim,suse.com:email,suse.com:mid,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns];
	FROM_HAS_DN(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	RCPT_COUNT_FIVE(0.00)[5];
	DKIM_TRACE(0.00)[suse.com:+]
X-Spam-Flag: NO

An NFS root mounted over NFSv4 against a Linux NFS server hangs during
boot, either wedging permanently in the switch-root exec or, on a loaded
machine, spinning until the softlockup watchdog fires.

The flexfiles layout driver reaches nfs4_pnfs_ds_connect() on the first
I/O through a layout segment.  For an NFSv3 data server that calls
symbol_request(nfs3_set_ds_client), which becomes
request_module("symbol:nfs3_set_ds_client") when nfsv3 is not already
resident.  request_module() execs /sbin/modprobe via the usermode
helper, and on an NFS root that binary -- and libkmod, and the libraries
behind it -- must be read from the very filesystem whose I/O is blocked
waiting on this DS connection to be established.  The helper cannot make
progress, so neither can the mount.

On a system whose init is on NFS the first such I/O is typically the
execve() of init itself, immediately after pivot_root(), at which point
the initramfs -- and the only reachable copy of modprobe -- is gone:

  WARNING: fs/nfs/pnfs_nfs.c:792 at nfs4_pnfs_ds_connect+0x47e/0x490 [nfsv4], CPU#0: systemd/1
  Modules linked in: nfs_layout_flexfiles rpcsec_gss_krb5 krb5 auth_rpcgss
                     nfsv4 dns_resolver nfs lockd grace netfs af_packet [...]
  Call Trace:
   nfs4_pnfs_ds_connect+0x47e/0x490 [nfsv4]
   nfs4_ff_layout_prepare_ds+0x...  [nfs_layout_flexfiles]
   ff_layout_choose_ds_for_read+0x...
   ff_layout_pg_init_read+0x...
   nfs_pageio_add_request+0x...
   nfs_readahead+0x...
   filemap_read+0x...
   __kernel_read+0x...
   bprm_execve+0x...
   do_execveat_common.isra.0+0x...
   __x64_sys_execve+0x...

Note the absence of nfsv3 from the module list.

This has been latent since the flexfiles driver was added, because a
fatal DS connect error used to be absorbed: ff_layout_read_pagelist()
returned PNFS_NOT_ATTEMPTED and pnfs_do_read() reissued the I/O through
pnfs_read_through_mds().  The read completed over plain NFSv4 against
the metadata server and nobody noticed that the layout had been
abandoned.

Commit 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on
fatal DS connect errors") removes that fallback for layouts carrying
FF_FLAGS_NO_IO_THRU_MDS, correctly, since silently contradicting the
flag was a bug.  But nfsd sets that flag on every layout it hands out
(fs/nfsd/flexfilelayout.c: FF_FLAGS_NO_LAYOUTCOMMIT |
FF_FLAGS_NO_IO_THRU_MDS | FF_FLAGS_NO_READ_IO, unconditionally), so
against a Linux server the no-fallback path is not the appliance corner
case the commit describes -- it is every layout.  With no fallback left,
a DS connect that cannot complete is now fatal to the boot.

FF_FLAGS_NO_READ_IO does not save the read: the client only diverts
reads off IOMODE_RW segments, and a read-only NFS root is served
IOMODE_READ segments, where the flag does not apply.

Declare the dependency via MODULE_SOFTDEP("pre: nfsv3") instead of
discovering it at I/O time.  The layout driver is itself loaded by
request_module("nfs-layouttype4-4") from find_pnfs_driver() during
mount(), which on an initramfs boot happens while the initramfs and a
working /sbin/modprobe are still in place, so a softdep is resolved at a
point where the usermode helper can actually run.

This pulls in nfsv3 whenever the flexfiles driver is loaded, including
for layouts whose data servers all speak NFSv4.1 and which would never
have needed it.  That seemed the better trade against an unbootable
system.

Reported on openSUSE Tumbleweed with kernel 7.2.2 under QEMU,
reproducible with dracut's TEST-60-NFS suite against any knfsd built with
CONFIG_NFSD_FLEXFILELAYOUT=y.  Booting with rd.driver.pre=nfsv3, which
loads the module from the initramfs before the pivot, is a complete
workaround and confirms the diagnosis.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Cc: stable@vger.kernel.org
Assisted-by: Claude Opus 5 <noreply@anthropic.com>
Signed-off-by: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..12a4a7908fe3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -3079,7 +3079,7 @@ static void __exit nfs4flexfilelayout_exit(void)
 }
 
 MODULE_ALIAS("nfs-layouttype4-4");
-
+MODULE_SOFTDEP("pre: nfsv3");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("The NFSv4 flexfile layout driver");
 
-- 
2.51.0

