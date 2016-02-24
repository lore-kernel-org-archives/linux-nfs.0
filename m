Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:50779 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755385AbcBXR4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:22 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/2] Add multihostname support for NFSv4.1,2
Date: Wed, 24 Feb 2016 12:55:57 -0500
Message-ID: <1456336559-17334-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This code requires the kernel "Version 2 NFSV4.1,2 session trunking"
patch set.

Note that while being useful for testing, it is not yet decided if
expressing session trunking hosts in this manner is the best way forward.

Andy Adamson (2):
  NFS parse NFSv4 multiple hostnames
  NFS add multiaddr mount option

 utils/mount/parse_dev.c | 30 ++++++++++++++++--------
 utils/mount/parse_dev.h |  2 +-
 utils/mount/stropts.c   | 62 ++++++++++++++++++++++++++++++++++++++++++++++++-
 utils/mount/utils.c     |  2 +-
 4 files changed, 83 insertions(+), 13 deletions(-)

-- 
1.8.3.1

