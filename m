Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61467 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584Ab2K2DRt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 22:17:49 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] NFSD: Add support for session dynamic slot management
Date: Wed, 28 Nov 2012 22:17:39 -0500
Message-Id: <1354159063-17343-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series adds support for session dynamic slot management
in accordance with Section 2.10.6.1 of RFC5661.

It implements a very simple policy that is controlled by the function
nfsd4_sequence_adjust_slot_table(): If the client is matching the server
target_highest_slotid, then we increase the window size by 1/4. Otherwise
we try to shrink the window.

The window size is bounded from below by the negotiated session table size
for backward compatibility with clients that do not support dynamic slot
management.

Trond Myklebust (4):
  NFSD: Convert the slot table to use a linked list
  NFSD: Make DRC memory limits work with dynamic slot allocation
  NFSD: Add slot table support for target_highest_slotid and
    highest_slotid
  NFSD: Add support for dynamic slot changes

 fs/nfsd/nfs4state.c | 279 ++++++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfs4xdr.c   |   7 +-
 fs/nfsd/nfsd.h      |   4 +-
 fs/nfsd/nfssvc.c    |   4 +-
 fs/nfsd/state.h     |  15 ++-
 fs/nfsd/xdr4.h      |   6 +-
 6 files changed, 240 insertions(+), 75 deletions(-)

-- 
1.7.11.7

