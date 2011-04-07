Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57766 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab1DGQha (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 12:37:30 -0400
Received: by iwn34 with SMTP id 34so2629173iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Apr 2011 09:37:29 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] NFSROOT short subjects
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 07 Apr 2011 12:37:27 -0400
Message-ID: <20110407163304.8531.18745.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

These visit the NFSROOT default mount option issues we discussed at LSF.

The first patch fixes a regression reported in 2.6.38, and should go to
linux-next as soon as possible for testing, then onto 2.6.38-stable and
2.6.39-rc.

The second patch (untested) should also be made available to linux-next
but can go into 2.6.40.  I decided to keep the choices simple.

---

Chuck Lever (2):
      NFSROOT: Select default mount options via Kconfig
      NFS: Revert NFSROOT default mount options


 fs/nfs/Kconfig   |   13 +++++++++++++
 fs/nfs/nfsroot.c |    6 +++++-
 2 files changed, 18 insertions(+), 1 deletions(-)

-- 
Chuck Lever
