From: andros@netapp.com
Subject: (unknown)
Date: Wed, 12 May 2010 10:44:12 -0400
Message-ID: <1273675462-15758-1-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461Ab0ELOpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:00 -0400
Subject: 
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


All layout drivers returned -1 or 0 for both get_read_threshold and
get_write_threshold policy operations. Remove the threshold policy ops and
the related helper functions.

Note that the threshold

0001-SQUASHME-pnfs_submit-remove-filelayout-get-threshold.patch
0002-SQUASHME-pnfs_submit-don-t-use-pnfs_use_read.patch
0003-SQUASHME-pnfs_submit-don-t-use-pnfs_use_write.patch
0004-SQUASHME-pnfs_submit-don-t-use-pnfs_use_write-for-co.patch
0005-SQUASHME-pnfs_submit-don-t-use-pg_threshold.patch
0006-SQUASHME-pnfs_submit-remove-pg_threshold.patch
0007-SQUASHME-pnfs_submit-don-t-use-below_threshold-in-re.patch
0008-SQUASHME-pnfs_submit-don-t-use-below_threshold-in-di.patch
0009-SQUASHME-pnfs_submit-remove-unused-threshold-calcula.patch
0010-SQUASHME-pnfs_submit-cleanup-filelayout-pg_test.patch

Note: these will not be restored.

Testing:
--------
CONFIG_NFS4_V1 set:
v4, v4.1, pNFS mounts Connectathon passes

CONFIG_NFS4_V1 not set:
v4 mount Connectathon passes

-->Andy

