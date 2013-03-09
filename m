Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759980Ab3CIAdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 19:33:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] some 4.1 session races
Date: Fri,  8 Mar 2013 19:33:38 -0500
Message-Id: <1362789221-4246-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These are a couple fixes for 4.1 session races, to be queued up for
3.10.

There are still some more races having to do with attempting to use an
expiring client from a 4.1 compound.

J. Bruce Fields (2):
  nfsd4: fix race on client shutdown
  nfsd4: fix use-after-free of 4.1 client on connection loss

 fs/nfsd/nfs4state.c |   14 +++++++++-----
 fs/nfsd/nfs4xdr.c   |    1 -
 fs/nfsd/state.h     |    2 --
 3 files changed, 9 insertions(+), 8 deletions(-)

-- 
1.7.9.5

