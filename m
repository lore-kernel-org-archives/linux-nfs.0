Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14144 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754885Ab0IRDSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 23:18:33 -0400
Received: from localhost.localdomain (scher1-lxp.hq.netapp.com [10.58.61.44] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8I3IEV2012071
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 20:18:15 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/12] RFC: pnfs: LAYOUTGET/DEVINFO submission, v2
Date: Fri, 17 Sep 2010 23:17:42 -0400
Message-Id: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This fixes various issue brought up in comments to the previous version.

Among the more substantial changes:

find_pnfs_driver now grabs module reference
driver init/uninit_mountpoint argument changed to struct nfs_server
io_ops moved into pnfs_layoutdriver_type
handling of pnfs_layout_from_open_stateid changed
file driver no longer uses vmalloc
deviceid moved from general to driver layer
CONFIG_PNFS_FILE_LAYOUT removed, just uses CONFIG_NFS_V4_1
error handling of LAYOUTGET and GETDEVICEINFO rpc calls changed

For those interested, the patches can also be found at
git://linux-nfs.org/~iisaman/linux-pnfs.git,
under the branch devinfo-submit-rc4-trond

A rebase of Benny's pnfs-submit branch onto these patches is under
the branch bennys-pnfs-submit-on-devinfo-rc4

Fred


This is the start of code implementing pnfs, based on RFC 5661.  Since
sending the whole thing at once would be overwhelming, we are trying
to break it into bite sized chunks.  This chunk implements the
mount/umount infrastructure, as well as sending the LAYOUTGET and
GETDEVTICEINFO calls on io (but not actually using the information for
io).  Note that two major simplifications to the protocol will be made 
throughout the initial submission process:  only the file layout
driver is considered, and only whole file layouts are requested.


These patches apply against Trond's nfs-for-2.6.37 branch.

patches 01-08 implement the mount/umount hooks
patches 09-12 implement LAYOUTGET and GETDEVICEINFO

