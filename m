Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42218 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217Ab0IVWFj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 18:05:39 -0400
Received: from localhost.localdomain (vikramyadav.hq.netapp.com [10.58.61.118] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8MM5M8K020412
	for <linux-nfs@vger.kernel.org>; Wed, 22 Sep 2010 15:05:23 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/12] RFC: pnfs: LAYOUTGRT/DEVINFO submission, v3
Date: Wed, 22 Sep 2010 18:04:58 -0400
Message-Id: <1285193110-24073-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This fixes various issue brought up in comments to the previous version.

Major changes are:
bugfixes and renames in the deviceid cache
fix Kconfig using a suggestion from Trond
moved module_get to simplify and avoid bug in find_pnfs_driver_locked

For those interested, the patches can also be found at
git://linux-nfs.org/~iisaman/linux-pnfs.git,
under the branch devinfo-submit-rc5-trond

A rebase of Benny's pnfs-submit branch onto these patches is under
the branch bennys-pnfs-submit-on-devinfo-rc5





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

