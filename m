Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:35801 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932321AbcFOQ7C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 12:59:02 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
Date: Wed, 15 Jun 2016 12:52:06 -0400
Message-Id: <1466009529-3421-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The majority of our lost delegation problems come from the inability
to return the delegations when the credentials that obtained them
have expired (conundrum mentioned in RFC 5661 18.35.3)

ObMemoryJog:

http://www.spinics.net/lists/linux-nfs/msg56230.html

v3: removal of OP_IS_PUTFH_LIKE checks
    added clarification of addressing the conundrum

Andrew Elble (3):
  nfs/nfsd: Move useful bitfield ops to a commonly accessible place
  nfsd: allow mach_creds_match to be used more broadly
  nfsd: implement machine credential support for some operations

 fs/nfsd/export.c        | 10 ++++++++++
 fs/nfsd/nfs4proc.c      | 39 +++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c     | 32 ++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c       | 51 ++++++++++++++++++++++---------------------------
 fs/nfsd/nfsd.h          |  5 +++++
 fs/nfsd/state.h         |  1 +
 fs/nfsd/xdr4.h          |  5 +++++
 include/linux/nfs4.h    | 11 +++++++++++
 include/linux/nfs_xdr.h | 11 -----------
 9 files changed, 119 insertions(+), 46 deletions(-)

-- 
2.6.3

