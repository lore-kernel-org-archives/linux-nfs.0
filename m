Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755599AbZLUWrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Dec 2009 17:47:01 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
Subject: [PATCH 0/2] nfsv4 back channel drc mininal implementation
Date: Mon, 21 Dec 2009 17:46:04 -0500
Message-Id: <1261435566-13814-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


nfs41: back channel drc minimal implementation
Patches against 2-6-33-rc1

For now the back channel ca_maxresponsesize_cached is 0 and there is no
backchannel DRC. Return NFS4ERR_REP_TOO_BIG_TO_CACHE when a cb_sequence
cachethis is true.  When it is false, return NFS4ERR_RETRY_UNCACHED_REP as the
next operation error.

0001-nfs41-prepare-for-back-channel-drc.patch
0002-nfs41-back-channel-drc-minimal-implementation.patch

Tested:
CONFIG_NFS_V4_1
NFSv4.1 mount: Connectathon passes.

Hardcoded a pyNFS server to always replay a cb_recall. Tested with cachethis of
True and False. Then held a RO file open and performed a RW open from a different client to force a recall.  This could be added to testclient.py


NFSv4.0 mount: Connectatahon passes.

-->Andy

