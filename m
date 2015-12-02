Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:36938 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754495AbbLBOkD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 09:40:03 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC 0/4] Deal with lost delegations and EKEYEXPIRED
Date: Wed,  2 Dec 2015 09:39:49 -0500
Message-Id: <1449067193-53310-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've finally discovered that the majority of our lost delegation problems
come from EKEYEXPIRED. This seems to work fine in our environment, but
I am unsure of the ramifications of this in a broader context, so it's
time to get other folks to look at it.

Andrew Elble (4):
  nfs/nfsd: Move useful bitfield ops to a commonly accessible place
  nfs: machine credential support for additional operations
  nfsd: allow mach_creds_match to be used more broadly
  nfsd: implement machine credential support for some operations

 fs/nfs/nfs4proc.c         | 20 +++++++++++++++++
 fs/nfsd/export.c          |  4 ++++
 fs/nfsd/nfs4proc.c        | 55 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c       | 35 ++++++++++++++++++++++++------
 fs/nfsd/nfs4xdr.c         | 51 ++++++++++++++++++++-----------------------
 fs/nfsd/nfsd.h            |  1 +
 fs/nfsd/state.h           |  1 +
 fs/nfsd/xdr4.h            |  5 +++++
 include/linux/nfs4.h      | 11 ++++++++++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   | 11 ----------
 11 files changed, 149 insertions(+), 46 deletions(-)

-- 
2.6.3

