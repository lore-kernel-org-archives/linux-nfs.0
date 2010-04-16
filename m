Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22196 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758229Ab0DPPwt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 11:52:49 -0400
From: andros@netapp.com
To: pnfs@linux.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pNFS generic device ID cache 
Date: Fri, 16 Apr 2010 11:52:52 -0400
Message-Id: <1271433175-4631-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch set implements a shared RCU device ID cache servicing multiple
mounts of a single layout type per meta data server (struct nfs_client).

0001-pnfs_submit-generic-device-ID-cache.patch
0002-pnfs_submit-fix-multiple-mount-set_pnfs_layoutdriver.patch
0003-pnfs-submit-file-layout-driver-generic-device-ID-cac.patch

These patches apply to the 2.6.34-rc3 pnfs branch below the following patch
which is the head of the revert patches - otherwise known as the first patch
not included in the pnfs file layout driver submission.

9a75b7356ca22b10903b507383646201cdcc9020

pnfs: filelayout: CB_NOTIFY_DEVICE support

    This reverts commit 933b55c15ed2b7fd89d8e0342bd5b2825726201a
    "SQUASHME pnfs_submit: remove filelayout CB_NOTIFY_DEVICE support"

Testing:

CONFIG_NFS_V4_1 set:

NFSv4.1/pNFS mounts:
Connectathon tests pass against GFS2/pNFS with a single AUTH_SYS mount, a double
AUTH_SYS mount, and an AUTH_SYS and AUTH_GSS/KRB5 mount (which creates
two superblocks under a struct nfs_client and both share the device id cache).

NFSv4.0 mount;
Connectathon tests pass

Did not test with multiple device ID's. I will create a mulitple device ID
test with the pynfs file layout server.

CONFIG_NFS_V4_1 not set:

NFSv4.0 mount: Connectathon tests pass.


-->Andy

