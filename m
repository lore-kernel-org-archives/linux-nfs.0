Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbaLCNzY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2014 08:55:24 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB3DtNqk030072
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Dec 2014 08:55:24 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-56-57.rdu2.redhat.com [10.10.56.57])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB3DtM9a019298
	for <linux-nfs@vger.kernel.org>; Wed, 3 Dec 2014 08:55:23 -0500
Message-ID: <547F164A.5000503@RedHat.com>
Date: Wed, 03 Dec 2014 08:55:22 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "nfs >> Linux NFS Mailing list" <linux-nfs@vger.kernel.org>
Subject: Fwd: [RHEL7.1 PATCH 0/5][BZ1166845] NFSv4.x: Delegation return causes
 infinite loop and hung
References: <1417544515-7381-1-git-send-email-steved@redhat.com>
In-Reply-To: <1417544515-7381-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Would it be possible to get these review and (hopefully) acked 
relatively soon?  I'm trying to get them into the rhel7-fs 
and they need to be acked up ;-) 

tia,

steved.


-------- Forwarded Message --------
Subject: [RHEL7.1 PATCH 0/5][BZ1166845] NFSv4.x: Delegation return causes infinite loop and hung
Date: Tue,  2 Dec 2014 13:21:50 -0500
From: Steve Dickson <steved@redhat.com>
To: Red Hat Kernel List <rhkernel-list@redhat.com>
CC: Red Hat NFS Team <nfs-team@redhat.com>

Here is a late breaking bug that was found by the Netapp QA people

Description of problem:
  When an NFS client receives an error while trying to return a delegation, it 
  leads to infinite state recovery (and hung machine).

As usual, as soon as this hits one of our kernel, they will
be more than willing to help out with testing.

bz: https://bugzilla.redhat.com/show_bug.cgi?id=1166845

Trond Myklebust (5):
  NFSv4: Ensure that we remove NFSv4.0 delegations when state has
    expired
  NFSv4: Ensure that we call FREE_STATEID when NFSv4.x stateids are
    revoked
  NFS: Don't try to reclaim delegation open state if recovery failed
  NFSv4: Fix races between nfs_remove_bad_delegation() and delegation
    return
  NFSv4.1: nfs41_clear_delegation_stateid shouldn't trust
    NFS_DELEGATED_STATE

 fs/nfs/delegation.c            | 25 ++++++++++++--
 fs/nfs/delegation.h            |  1 +
 fs/nfs/filelayout/filelayout.c |  3 --
 fs/nfs/nfs4proc.c              | 76 +++++++++++++++++++++++-------------------
 4 files changed, 65 insertions(+), 40 deletions(-)

-- 
1.8.3.1



