Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:49102 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaLBMrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 07:47:37 -0500
Subject: [PATCH 0/3] nfs-utils build fixes
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Date: Tue, 02 Dec 2014 13:39:49 +0100
Message-ID: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series fixes some of the snafus I encountered when
trying to build nfs-utils for OpenELEC (meaning: lots of static
libraries, cross compile, separate source and build dirs).

Only the first patch is a real patch, the other two are more
a basis for discussion since I'm not sure about the best approach...

---

David Härdeman (3):
      nfs-utils: fix gssd build flags
      [RFC] nfs-utils: change internal rpcgen to support separate builddir
      [RFC] nfs-utils: include headers from srcdir


 configure.ac            |    3 +++
 tools/rpcgen/rpc_main.c |    7 ++++---
 utils/gssd/Makefile.am  |    4 ++--
 3 files changed, 9 insertions(+), 5 deletions(-)

--
David Härdeman
