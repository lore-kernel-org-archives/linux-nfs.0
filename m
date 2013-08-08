Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30405 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934262Ab3HHO6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 10:58:03 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/2] NFSv4.1 Use clientid management rpc_clnt
Date: Thu, 8 Aug 2013 10:57:54 -0400
Message-ID: <1375973876-2522-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 2 changes:

remove the fs_locations patch
add code comments as per review

Testing: SECINFO against a filer. Still need to test SECINFO_NO_NAME


Andy Adamson (2):
  NFSv4.1 Use clientid management rpc_clnt for secinfo
  NFSv4.1 Use clientid management rpc_clnt for secinfo_no_name

 fs/nfs/nfs4proc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

-- 
1.8.3.1

