Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933330Ab0GOQNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 12:13:45 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] pnfs-submit layoutdriver api parameter consolidation
Date: Thu, 15 Jul 2010 12:13:47 -0400
Message-Id: <1279210434-2772-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Compile fix.
0001-SQUASHME-pnfs-submit-fix-CONFIG_NFS_V4_1-not-set-com.patch

The read_pagelist, write_pagelist, and commit layoutdriver io operations
parameters are all serviced by either nfs_write_data or nfs_read_data
fields. Just pass in the data structs.

0002-SQUASHME-pnfs-submit-consolidate-read_pagelist-param.patch
0003-SQUASHME-pnfs-submit-filelayout-use-new-read_pagelis.patch
0004-SQUASHME-pnfs-submit-consolidate-write_pagelist-para.patch
0005-SQUASHME-pnfs-submit-filelayout-use-new-write_pageli.patch
0006-SQUASHME-pnfs-submit-consolidate-commit-parameters.patch
0007-SQUASHME-pnfs-submit-filelayout_commit-use-new-API.patch

Testing

CONFIG_NFS_V4_1 set:
Connectathon passes

CONFIG_NFS_V4_1 not set:
Connectathon passes

-->Andy

