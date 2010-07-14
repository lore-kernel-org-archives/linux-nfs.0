Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612Ab0GNRFO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 13:05:14 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] zero layout stateid on last layout segment removal
Date: Wed, 14 Jul 2010 13:05:07 -0400
Message-Id: <1279127108-2553-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


This is a piece of the "pnfs-submit Re-initialize pnfs_layout_type when segs
list is emtpy" patch set that I think is not being argued about.

More initialization needs to occur when the layout->segs list is empty.

This patch fixes the bug where a layoutreturn would empty the nfs_inode->layout
segs list, and a future layoutget would use a (now-stale) stateid instead of
creating a new layout stateid from an existing open/lock/deleg stateid.

layoutget decides to get a new stateid when the nfs_layout->layout->stateid is
zeroed.

Testing;

CONFIG_NFS_V4_1 set:
Passes Connectathon (pnfs mount).
Behaves correctly in pyNFS file layout server tests where return-on-close is
set - every layoutget uses a new stateid.

CONFIG_NFS_V4_1 not set:
NFsv4.0 passses connectathon

-->Andy
