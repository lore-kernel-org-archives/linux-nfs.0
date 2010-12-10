Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56510 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab0LJGIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:41 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLb023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:31 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/22] pnfs more wave2 patches
Date: Thu,  9 Dec 2010 20:22:35 -0500
Message-Id: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are on top of the current pnfs-submit rebased onto 2.6.37-rc5,
per Benny's suggestion.

More wave2 (CB_LAYOUTRECALL and LAYOUTRETURN) patches, based on
internal review as well as comments from Trond.  These implement a completely
forgetful model.  The client will *never* send LAYOUTRETURN.  We also
don't do any waiting in LAYOUTGET, instead falling back to MDS at the
smallest sign of trouble.

patches 1 - 7 revert previous roc changes, which are unecessary given
that we are not returning anything

patch 8 reverts a fix already done in mainline in a different way

patch 9 prevents a pointless reordering in the cumulative diff

patch 10 fixes a COMMIT bug tickled by the new code

patch 11 - 20 remove LAYOUTRETURN and fix various review issues

patch 21 just brings an existing post-submit patch into the submit branch

patch 22 turns off LAYOUTCOMMIT.  It is a temporary stop gap until
code can be rearranged so the LAYOUTCOMMIT code can be easily pushed
outside of the pnfs-submit branch

Fred

