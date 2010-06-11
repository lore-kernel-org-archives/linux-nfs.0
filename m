From: andros@netapp.com
Subject: [PATCH 0/1] pnfsd fix dlm device naming
Date: Fri, 11 Jun 2010 12:45:33 -0400
Message-ID: <1276274734-4996-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53612 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756453Ab0FKQqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 12:46:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Applies against 2.6.35-rc2 pnfsd-files branch.

Use bdevname to find the file system device name. Note that this means there is
no longer a leading '/dev' in the /proc/fs/nfsd/pnfs_dlm_device device
name format.

0001-pnfsd-fix-dlm-device-naming.patch

-->Andy

