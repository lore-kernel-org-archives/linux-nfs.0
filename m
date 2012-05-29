Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758278Ab2FAVBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 17:01:36 -0400
From: andros@netapp.com
To: iisaman@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Andy Adamson <andros@fedora-64-2.gateway.2wire.net>
Subject: [PATCH 0/6] PYNFS various patches
Date: Tue, 29 May 2012 17:57:53 -0400
Message-Id: <1338328679-28837-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@fedora-64-2.gateway.2wire.net>

Here is what I've been using to test DS recovery and MDSThreshold

-->Andy

Andy Adamson (3):
  PYNFS use requested iomode on layoutget
  PYNFS: add mdsthreshold to file layout server
  PYNFS implement FREE_STATEID and TEST_STATEID operations

Fred Isaman (1):
  PYNFS rpc drop fix

Weston Andros Adamson (2):
  PYNFS fix rpcgen
  PYNFS use loopback addresses for MDS<->DS communication

 nfs4.1/dataserver.py |   28 ++++++++++++++++++++++------
 nfs4.1/fs.py         |   12 ++++++++++--
 nfs4.1/nfs4lib.py    |    2 +-
 nfs4.1/nfs4server.py |   33 +++++++++++++++++++++++++++++++++
 nfs4.1/nfs4state.py  |   11 ++++++-----
 rpc/rpc.py           |    2 +-
 xdr/xdrgen.py        |    2 ++
 7 files changed, 75 insertions(+), 15 deletions(-)

-- 
1.7.7.6

