Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35537 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab0ELRkK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 13:40:10 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Use MDS session for dual role MDS/DS 
Date: Wed, 12 May 2010 13:39:37 -0400
Message-Id: <1273685980-3340-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Plus some clean ups.

Use the MDS session for the data server traffic only
if EXCHGID4_FLAG_USE_PNFS_DS is set as an MDS clientid pNFS role

0001-SQUASHME-pnfs_submit-use-MDS-session-for-dual-MDS-DS.patch
0002-SQUASHME-pnfs_submit-update-DS-nfs4_set_client.patch
0003-SQUASHME-pnfs_submit-cleanup-DS-exchange-flag-proces.patch


Testing:
CONFIG_NFS_V4_1 set:
pNFS, NFSv41, NFSv4 mount passes Connectathon tests.
    
CONFIG_NFS_V4_1 not set:
NFSv4 mount passes Connectathon tests.

-->Andy

