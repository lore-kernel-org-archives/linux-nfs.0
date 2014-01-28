Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:43757 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755422AbaA1XBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jan 2014 18:01:21 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1 free slot before resending I/O to MDS
Date: Tue, 28 Jan 2014 18:01:13 -0500
Message-ID: <1390950074-7245-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replaces NFSv4.1 Do not pre-allocate slots in nfs4_end_drain_slot_tbl.

Andy Adamson (1):
  NFSv4.1 free slot before resending I/O to MDS

 fs/nfs/nfs4filelayout.c | 6 ++++++
 fs/nfs/nfs4session.c    | 1 +
 2 files changed, 7 insertions(+)

-- 
1.8.3.1

