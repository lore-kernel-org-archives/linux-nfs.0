From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/2] More writeback code cleanups
Date: Mon, 16 Jun 2008 15:23:48 -0400
Message-ID: <20080616192348.20513.72423.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4260 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbYFPTe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 15:34:28 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5GJY624006530
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jun 2008 12:34:27 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series includes one cleanup of the nfs_update_request
function, and a patch to allow redirtying of unstable writes without
first sending an unnecessary COMMIT request.

They will be added to the 'devel' branch of the git tree at
  git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
