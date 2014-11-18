Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbaKROGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:45 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jMO025264
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6iGk030991
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:44 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] mount.nfs default version
Date: Tue, 18 Nov 2014 09:06:38 -0500
Message-Id: <cover.1416319371.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's the work posted yesterday broken out a bit with an addition of
enabling nfsmount.conf by default, and the change to autonegotiate starting
with version 4.2 (instead of 4.0) when no version is specified in either
config or mount option.

Benjamin Coddington (6):
  mount.nfs: default enable mount config file (nfsmount.conf)
  mount.nfs: fix a comment typo in parse options
  mount.nfs: parse options - add helper po_contains_prefix
  mount.nfs: Add struct nfs_version and generalize version parsing
  nfsmount.conf: Always parse versions
  mount.nfs: configurable minor version defaults

 configure.ac             |    8 +-
 utils/mount/configfile.c |   36 +-----------
 utils/mount/network.c    |  122 ++++++++++++++++++-------------------
 utils/mount/network.h    |   15 ++++-
 utils/mount/nfsumount.c  |    4 +-
 utils/mount/parse_opt.c  |   26 ++++++++-
 utils/mount/parse_opt.h  |    2 +
 utils/mount/stropts.c    |  150 +++++++++++++++++++++++++++++++---------------
 8 files changed, 209 insertions(+), 154 deletions(-)

