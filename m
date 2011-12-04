Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41983 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378Ab1LDRYv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 12:24:51 -0500
Received: by eaak14 with SMTP id k14so3643971eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 09:24:50 -0800 (PST)
Message-ID: <4EDBACDD.3010609@tonian.com>
Date: Sun, 04 Dec 2011 19:24:45 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.2-rc4-2011-12-04
References: <4EC13EEA.3030404@tonian.com>
In-Reply-To: <4EC13EEA.3030404@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I rebased the pnfs tree onto v3.2-rc4.

The spnfs was dropped as it became obsolete and effectively unmaintained
over time.

Correspondingly, the spnfs-block branch is now renamed to pnfsd-block.

The following patches were merged since last update pnfs-all-3.2-rc1-2011-11-14:

pnfs-block:
  Peng Tao         a8c4a0a pnfsblock: don't spinlock when freeing block_dev
  Peng Tao         507cca8 pnfsblock: limit bio page count
  Benny Halevy     f902b81 DEBUG: pnfs: printouts
  Benny Halevy     9fcea77 pnfsblock: add devid debug printouts

pnfsd:
  Benny Halevy     b46ad6f SQUASHME: pnfsd: add missing nfs4_unlock_state in nfs4_pnfs_return_layout
  Benny Halevy     7600a80 DEBUG: pnfsd: printouts

pnfsd-block:
  Benny Halevy     788afe2 DEBUG: pnfsd: printouts
  Benny Halevy     e99329f pnfsd-block: reverse boolean_t values so they make sense
  Benny Halevy     ace859c pnfsd-block: change blr_lock to mutex
  Benny Halevy     79f0540 pnfsd-block: dprint fiemap rval
  Benny Halevy     6893935 pnfsd-block: allow positive fiemap rval
  Benny Halevy     0fa92ba pnfsd-block: use SECT_SIZE helper macros
  Benny Halevy     58590f7 pnfsd-block: undo dependence on spnfs
  Benny Halevy     6937255 pnfsd-block: set the sbid part of the deviceid

Benny
