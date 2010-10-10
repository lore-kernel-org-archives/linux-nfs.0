Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30725 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816Ab0JOGRj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:39 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/12] RFC: pnfs: LAYOUTGET/DEVINFO submission, try 4
Date: Sun, 10 Oct 2010 11:22:41 -0400
Message-Id: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is try 4 of the first wave of the linux pnfs client submission.
This fixes some issues seen at the recent bakeathon, and includes
fixes noted since the last version was published in Benny's tree.

Major changes are:
fix problems due to uninitialized flag when using v2/3
fix deadlock caused by free_lseg sleeping
properly update stateid, instead of blindly overwriting
fix error handler for LAYOUTGET

A complete change set can be found at
git://linux-nfs.org/~iisaman/linux-pnfs.git,
branch devinfo-submit-rc6-needs-squashed

For those interested, the patches themselves can also be found under
the branch devinfo-submit-rc6-trond

A rebase of Benny's pnfs-submit branch onto these patches is under
the branch bennys-pnfs-submit-on-devinfo-rc6





This is the start of code implementing pnfs, based on RFC 5661.  Since
sending the whole thing at once would be overwhelming, we are trying
to break it into bite sized waves.  This first wave implements the
mount/umount infrastructure, as well as sending the LAYOUTGET and
GETDEVTICEINFO calls on io (but not actually using the information for
io).  Note that two major simplifications to the protocol will be made 
throughout the initial submission process:  only the file layout
driver is considered, and only whole file layouts are requested.


These patches apply against Trond's nfs-for-2.6.37 branch.

patches 01-08 implement the mount/umount hooks
patches 09-12 implement LAYOUTGET and GETDEVICEINFO

