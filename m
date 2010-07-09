Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757754Ab0GIQjk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jul 2010 12:39:40 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] pnfs-submit Re-initialize pnfs_layout_type when segs list is empty
Date: Fri,  9 Jul 2010 12:39:29 -0400
Message-Id: <1278693571-3328-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


e keep the nfs_inode->layout when the segs list is empty, and we remove it
from the nfs_client cl_layouts list, but we fail to reset the other fields.
Re-initialize the layout (all except for the refcount) so that the next
layoutget with potentially new deviceid.... sets the layout fields.

Note: API change to layoutdriver_io_operations free_layout

0001-SQUASHME-pnfs-submit-reinitialize-pnfs_layout_type.patch
0002-SQUASHME-pnfs-submit-file-layout-free_layout-init_on.patch

Tested

CONFIG_V4_I set:
Connectathon tests pass against GFS2/pNFS and pyNFS file layout servers. Both
return-on-close and not return-on-close tested.

CONFIG_V4_I not set:
NFSv4.0 mount passes Connectathon tests.

-->Andy

