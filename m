Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47524 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab0IISKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 14:10:36 -0400
Received: from localhost.localdomain (surajit-lxp.hq.netapp.com [10.58.50.95] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o89IAW1L002948
	for <linux-nfs@vger.kernel.org>; Thu, 9 Sep 2010 11:10:32 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/13] RFC: pnfs: LAYOUTGET/DEVINFO submission
Date: Thu,  2 Sep 2010 14:00:06 -0400
Message-Id: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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
patches 09-13 implement LAYOUTGET and GETDEVICEINFO

