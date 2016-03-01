Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35069 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbcCASMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2016 13:12:50 -0500
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
To: miklos@szeredi.hu
Cc: linux-unionfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Fix overlayfs with NFS as lowerdir
Date: Tue,  1 Mar 2016 12:12:05 -0600
Message-Id: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS as the lower directory is not working with overlayfs because
the dentry operations have not been set correctly. However,
NFS evaluates inode and sb from the dentry, which may not be correct
when used with overlayfs. So, we store the inode in nfs_open_context
(which is translated using d_select_inode) and use it for any
inode related operations.

-- 
Goldwyn

