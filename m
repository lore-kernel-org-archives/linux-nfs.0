Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756678Ab0LNO7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 09:59:05 -0500
From: andros@netapp.com
To: trond.myklebuse@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH_V3 0/1] NFS fix the setting of exchange id flag Version 3 
Date: Tue, 14 Dec 2010 09:59:03 -0500
Message-Id: <1292338744-6926-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Add EXCHGID4_FLAG_BIND_PRINC_STATEID and EXCHGID4_FLAG_MASK_PNFS from RFC 5661.
Update EXCHGID4_FLAG_MASK_A and EXCHGID4_FLAG_MASK_R accordingly.

-->Andy
