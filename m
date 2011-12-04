Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55276 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab1LDNqV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:46:21 -0500
Received: by eaak14 with SMTP id k14so3592444eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:46:20 -0800 (PST)
Message-ID: <4EDB79A9.2080109@tonian.com>
Date: Sun, 04 Dec 2011 15:46:17 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/13] misc pnfsd patches
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[PATCH 01/13] SQUASHME: pnfsd: add missing nfs4_unlock_state in
[PATCH 02/13] DEBUG: pnfsd: printouts

[PATCH 03/13] pnfsd-block: reverse boolean_t values so they make
[PATCH 04/13] pnfsd-block: mv include/linux/nfsd4_block.h
[PATCH 05/13] pnfsd-block: do not override s_pnfs_op
[PATCH 06/13] pnfsd-block: change blr_lock to mutex
[PATCH 07/13] pnfsd-block: dprint fiemap rval
[PATCH 08/13] pnfsd-block: allow positive fiemap rval
[PATCH 09/13] pnfsd-block: use SECT_SIZE helper macros
[PATCH 10/13] pnfsd-block: undo dependence on spnfs
[PATCH 11/13] pnfsd-block: set the sbid part of the deviceid

[PATCH 12/13] DEBUG: pnfs: printouts
[PATCH 13/13] DEBUG: pnfsblock: add devid debug printouts
