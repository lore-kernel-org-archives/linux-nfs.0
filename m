Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbaKCRtg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Nov 2014 12:49:36 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com
Subject: [PATCH 0/2] nfsidmap not setting key timeouts
Date: Mon,  3 Nov 2014 12:49:31 -0500
Message-Id: <cover.1415036893.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These should fix up nfsidmap being unable to set key timeouts.

Benjamin Coddington (2):
  nfsidmap: set the correct DEFAULT_KEYRING string
  nfsidmap: Correct a failure to set key timeout values

 utils/nfsidmap/nfsidmap.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

