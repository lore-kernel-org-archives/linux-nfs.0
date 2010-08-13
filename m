Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880Ab0HMVcE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:04 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/50] Squashed and re-organized pnfs-submit tree
Date: Fri, 13 Aug 2010 17:31:12 -0400
Message-Id: <1281735122-1496-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0



Here is the pnfs-submit tree all squashed and reorganized. The resultant tree
is unchanged. The patch comments and Signed-off-by's need to be added.

We may want to split or re-order some of the patches. I left the "introduce
new file" patches #6-9 unsquashed, but we probably want to squash them into
the patch that uses them first.

Patches 1-4 are not pnfs patches, and should be submitted to Trond/Bruce.

Patch #50 "SQUASHME pnfs_submit: remove this unused code"
should not be squashed, but removed.

Patches 47,-49 are for the post-submit trees.

-->Andy

