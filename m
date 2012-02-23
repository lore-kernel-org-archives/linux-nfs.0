Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62221 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab2BWTol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 14:44:41 -0500
Received: by yhoo21 with SMTP id o21so807358yho.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 11:44:40 -0800 (PST)
Message-ID: <4F469726.50601@tonian.com>
Date: Thu, 23 Feb 2012 11:44:38 -0800
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.3-rc4-2012-02-22
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I merged the following patches into pnfs-all-3.3-rc4-2012-02-22
and rebased the tree onto v3.3-rc4

nfsd-next:
  Dan Carpenter    2343044 nfsd: don't allow zero length strings in cache_parse()
  Dan Carpenter    5ebc5d7 nfsd: remove some unneeded checks
  Stanislav Kinsbursky  c3855e4 SUNPRC: remove marking service temporary sockets with XPT_CHNGBUF
  J. Bruce Fields  5674b42 nfsd: cleanup setting of default max_block_size
  J. Bruce Fields  4cc07fa nfsd: fix default iosize calculation on 32bit
  J. Bruce Fields  379ce53 nfsd4: fix sessions slotid wraparound logic
  J. Bruce Fields  53ca43c nfsd4: rearrange struct nfsd4_slot
  J. Bruce Fields  804d780 nfsd4: check for uninitialized slot
  Tigran Mkrtchyan  ce27a11 nfsd4: initialize current stateid at compile time
  Tigran Mkrtchyan  fc21f4d nfsd41: handle current stateid in open and close
  Tigran Mkrtchyan  475f192 nfsd41: handle current stateid on lock and locku
  Tigran Mkrtchyan  3fe5cee nfsd41: consume current stateid on read and write
  Tigran Mkrtchyan  2944fce nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
  Tigran Mkrtchyan  6c9a965 nfsd41: save and restore current stateid with current fh
  Tigran Mkrtchyan  fa0bdac nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
  Tigran Mkrtchyan  19fd0e0 nfsd41: handle current stateid in SETATTR and FREE_STATEID
  Tigran Mkrtchyan  2c49ed3 nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
  Tigran Mkrtchyan  1e5d5c4 nfsd41: use current stateid by value
  Benny Halevy     89817ad nfsd41: share_access_to_flags should consider only nfs4.x share_access flags
  Benny Halevy     32f116e nfsd41: split out share_access want and signal flags while decoding
  Tom Tucker       2b6d232 svcrdma: Cleanup sparse warnings in the svcrdma module
  NeilBrown        8847415 lockd: fix arg parsing for grace_period and timeout.
  Bryan Schumaker  89a16f8 NFSD: Clean up the test_stateid function

nfsd-upstream:
  Benny Halevy     e77b654 nfsd41: refactor nfs4_open_deleg_none_ext logic out of nfs4_open_delegation
  Benny Halevy     958ac96 nfsd41: refactor nfsd4_deleg_xgrade_none_ext logic out of nfsd4_process_open2

pnfsd:
  Benny Halevy     fa8d72d pnfsd: add support for per-file layout_types attribute

pnfsd-exofs:
  Boaz Harrosh     e10ae7d SQUASHME: pnfsd-exofs: Fix the RAID5 export


