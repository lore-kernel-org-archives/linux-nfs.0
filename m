Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57752 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab1EQExF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 00:53:05 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Tue, 17 May 2011 14:52:17 +1000
Subject: [PATCH 0/2] Two small fixes for nfs-utils
Cc: linux-nfs@vger.kernel.org
Message-ID: <20110517045125.29020.14596.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been sorting through nfs-utils patches in suse and have two that
should go upstream.

Please consider for next release.

Thanks,
NeilBrown



---

Neil Brown (1):
      Remove risk of nfs_addmntent corrupting mtab

Suresh Jayaraman (1):
      supress socket error when address family is not supported


 support/nfs/nfs_mntent.c |    9 +++++++++
 utils/nfsd/nfssvc.c      |    9 +++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

-- 
Signature

