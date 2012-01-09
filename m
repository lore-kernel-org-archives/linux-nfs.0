Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60532 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab2AIICO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 03:02:14 -0500
Received: by eekc4 with SMTP id c4so2076596eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jan 2012 00:02:13 -0800 (PST)
Message-ID: <4F0A9F00.4020308@tonian.com>
Date: Mon, 09 Jan 2012 10:02:08 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.2-2012-01-08
References: <4EC13EEA.3030404@tonian.com> <4EDBACDD.3010609@tonian.com>
In-Reply-To: <4EDBACDD.3010609@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I rebased the pnfs tree onto v3.2

The following branches were added:
pnfs-obj - holding Boaz' latest fixes
pnfs-all-3.2 - equal to pnfs-all-latest, will be used to accumulate fixes for the v3.2-based tree.

Therefore the resulting tree structure is as follows:

master
	pnfs-block
		pnfs-obj
	nfsd-upstream
		nfsd41
			pnfsd
				pnfsd-exofs
					pnfsd-lexp
						pnfsd-block
							pnfs-all-latest (Merge pnfs-obj)

The following patches were merged since last update pnfs-all-3.2-rc4-2011-12-04:

pnfs-obj:
  Boaz Harrosh     2d78632 pnfs-obj: pNFS errors are communicated on iodata->pnfs_error
  Boaz Harrosh     ecf0d0e pnfs-obj: Must return layout on IO error

nfsd-upstream:
  J. Bruce Fields  bfb376b nfsd4: be forgiving in the absence of the recovery directory

pnfsd:
  Benny Halevy     9701606 SQUASHME: pnfsd: DEBUG: nfs4_bug_on_unlocked_state unused
  Benny Halevy     2e470a3 SQUASHME: pnfsd: DEBUG: conditionally dprint client_mutex_owner

pnfsd-block:
  Benny Halevy     74736a7 SQUASHME: pnfsd-block: mv include/linux/nfsd/nfsd4_block.h fs/nfsd/
  Benny Halevy     95457b4 SQUASHME: pnfsd-block: fix compile error when PNFSD_BLOCK in not enabled
  Benny Halevy     b95e17a pnfsd-block: bl_layoutreturn must return success when pnfsd_block is disabled

Benny
