Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:25544 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932342AbcARUIe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jan 2016 15:08:34 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, dros@primarydata.com, Andrew Elble <aweits@rit.edu>
Subject: [PATCH v2 0/3] Deal with lost delegations and EKEYEXPIRED
Date: Mon, 18 Jan 2016 15:08:19 -0500
Message-Id: <1453147702-42961-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've finally discovered that the majority of our lost delegation problems
come from EKEYEXPIRED. This seems to work fine in our environment, but
I am unsure of the ramifications of this in a broader context, so it's
time to get other folks to look at it.

v2: fix kbuild robot err on CONFIG_NFSD_V4 unset
    kerneldoc header on nfsd4_spo_must_allow
    removed LAYOUTRETURN as I currently can't test it

Andrew Elble (3):
  nfs/nfsd: Move useful bitfield ops to a commonly accessible place
  nfsd: allow mach_creds_match to be used more broadly
  nfsd: implement machine credential support for some operations

 fs/nfsd/export.c        |  4 +++
 fs/nfsd/nfs4proc.c      | 69 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c     | 32 ++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c       | 51 +++++++++++++++++-------------------
 fs/nfsd/nfsd.h          |  5 ++++
 fs/nfsd/state.h         |  1 +
 fs/nfsd/xdr4.h          |  5 ++++
 include/linux/nfs4.h    | 11 ++++++++
 include/linux/nfs_xdr.h | 11 --------
 9 files changed, 143 insertions(+), 46 deletions(-)

-- 
2.6.3

