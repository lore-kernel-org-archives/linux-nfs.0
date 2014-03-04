Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36487 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaCDRbR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 12:31:17 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/4] NFSv4 fix nfs4_stateid_is_current processing
Date: Tue, 4 Mar 2014 12:31:05 -0500
Message-ID: <1393954269-3974-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is an expanded version of the "NFSv4 always compare stateids in nfs4_stateid_is_current" patch I sent on Feb 27.

Found at Connectathon 2014 and NetApp internal testing.

nfs4_stateid_is_current is used on the NFSv4 I/O path to determine if a
stateid has changed. The idea is that if there is a stateid expire error
such as NFS4ERR_BAD_STATEID and the stateid used that induced the error has
changed, then we can just resend the RPC from the call prepare state with
the changed stateid instead of kicking off recovery as the changed stateid
indicates it already had been recovered.

This patch set fixes a false positive that resulted in an NFS4ERR_BAD_STATEID
infinite loop. Trond pointed out that the nfs4_select_rw_stateid -EIO error
is special in that it indicates a lost lock.

As I examined the use of nfs4_select_rw_stateid, I addressed some other errors
in the use of nfs4_set_rw_stateid and friends in setattr and filelayout
prepare functions.

Just tested with connectathon tests. Will test more once I'm back in town...

-->Andy


Andy Adamson (4):
  NFSv4 propagate nfs4_stateid_is_current errors
  NFSv4 Check errors on stateid changed functions in I/O path
  NFSv4 _nfs4_do_setattr use zero stateid on lost lock
  NFSv4.1 Fail data server I/O if stateid represents a lost lock

 fs/nfs/nfs4filelayout.c |  10 +++--
 fs/nfs/nfs4proc.c       | 116 ++++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4state.c      |   6 +++
 3 files changed, 100 insertions(+), 32 deletions(-)

-- 
1.8.3.1

