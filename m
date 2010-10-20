Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46757 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab0JTESL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 00:18:11 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/12] pnfs: LAYOUTGET/DEVINFO submission v5
Date: Wed, 20 Oct 2010 00:17:52 -0400
Message-Id: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is try 5 of the first wave of the linux pnfs client submission.
The only change (besides rebase on top of Trond's most recent
nfs-for-2.6.37 branch) between this series and the previous is that
owner/sign-off issues have been addressed, which allows us to
remove the RFC label of the previous series.

For those interested, the patches themselves can also be found at
git://linux-nfs.org/~iisaman/linux-pnfs.git,
branch devinfo-submit-rc7-trond


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

