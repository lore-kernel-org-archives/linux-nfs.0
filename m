Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14524 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790Ab0DZQSQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:18:16 -0400
From: andros@netapp.com
To: pnfs@linux-nfs.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pNFS generic device ID cache version 3
Date: Mon, 26 Apr 2010 12:18:16 -0400
Message-Id: <1272298699-11411-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


This patch set implements a shared RCU device ID cache servicing multiple
mounts of a single layout type per meta data server (struct nfs_client).

Device id's are referenced by layout segments which hold a pointer to the
nfs4_deviceid struct.

An hlist is used for the cache due to the large number of devices used by
the object and block layout drivers.

Note that nfs4_deviceid_hash() is the same as the NFSD opaque_hash function.
Perhaps they should be shared.

0001-SQUASHME-pnfs_submit-generic-device-ID-cache.patch
0002-SQUASHME-pnfs_submit-fix-multiple-mount-set_pnfs_lay.patch
0003-SQUASHME-pnfs-submit-file-layout-driver-generic-devi.patch

These patches apply to the 2.6.34-rc3 pnfs-submit branch.

Testing:
-------
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

