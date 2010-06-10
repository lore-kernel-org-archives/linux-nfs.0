From: andros@netapp.com
Subject: SQUASHME-pnfs-submit-write-to-MDS-on-DS-commit-verifier mismatch
Date: Thu, 10 Jun 2010 17:26:22 -0400
Message-ID: <1276205183-14014-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: iisaman@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756981Ab0FJV0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 17:26:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is an addition to Fred's "[PATCH 0/24] LAYOUTGET invocation"
patch set, and applies on top of it. In particular, it fixes the verifier
mismatch case in nfs_commit_release. The bad status case is handled in Fred's
patch:

"[PATCH 21/24] pnfs-submit:filelayout: rewrite filelayout_commit to use new API"

Fred - please consider adding this to your patch set submission.

SQUASHME-pnfs-submit-write-to-MDS-on-DS-commit-verif.patch

-->Andy

