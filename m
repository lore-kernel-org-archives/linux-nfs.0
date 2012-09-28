Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57175 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030952Ab2I1VFU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Sep 2012 17:05:20 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.0 reclaim reboot state when re-establishing clientid
Date: Fri, 28 Sep 2012 17:05:08 -0400
Message-Id: <1348866309-2049-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patch fixes an infinite loop where a file is open during a reboot, and 
written to after the reboot. NFS4ERR_BADSESSION is intially returned, and
first the session, and then the clientid are re-established.  But since the
open state was not recovered, the write after reboot would use the old stateid.
The server then returns NFS4ERR_STALE_STATEID as it should, and the client
then goes into the NFS4CLNT_CHECK_LEASE state which sends a solo sequence
operation to check the lease. Since the clientid/session has been
re-established, the NFS4CLNT_CHECK_LEASE does not receive an error, and the
write is resent with the old stateid.....


-->Andy

Andy Adamson (1):
  NFSv4.0 reclaim reboot state when re-establishing clientid

 fs/nfs/nfs4state.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.7.7.6

