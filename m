Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:15030 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbaLQSrb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 13:47:31 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFS: try RPC_AUTH_GSS_KRB5 after RPC_AUTH_GSS_KRB5I for cl_rpcclient
Date: Wed, 17 Dec 2014 13:47:22 -0500
Message-ID: <1418842043-15074-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

I'm not sure why in the -EACCES case for nfs4_discover_server_trunking,
nfs4_root_machine_cred(clp) is called, and then retry the detect_trunking call.

Andy Adamson (1):
  NFS: try RPC_AUTH_GSS_KRB5 after RPC_AUTH_GSS_KRB5I for cl_rpcclient

 fs/nfs/nfs4state.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

-- 
1.8.3.1

