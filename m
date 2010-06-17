Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56785 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757354Ab0FQTfb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:31 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] pnfs: merge sync and async layoutcommit calls
Date: Thu, 17 Jun 2010 15:34:49 -0400
Message-Id: <1276803296-9438-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Remove layout driver API calls unused by the file layout.
0001-SQUASHME-pnfs-submit-remove-setup_layoutcommit.patch
0002-SQUASHNE-pnfs-submit-remove-cleanup_layoutcommit.patch
0003-SQUASHME-pnfs-submit-remove-encode_layoutcommit.patch

0004-pnfs-submit-merge-sync-and-async-layoutcommit.patch

Restore the layout API calls for other drivers.
0005-pnfs-post-submit-restore-encode_layoutcommit.patch
0006-pnfs-post-submit-restore-cleanup_layoutcommit.patch
0007-pnfs-post-submit-restore-setup_layoutcommit.patch

-->Andy

