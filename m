Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267AbaLGVFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2014 16:05:49 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5n3k031815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
Received: from bcodding-csb.redhat.com (vpn-57-215.rdu2.redhat.com [10.10.57.215])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5n9s008405
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Two nfsd referral xdr encoding bugs
Date: Sun,  7 Dec 2014 16:05:46 -0500
Message-Id: <cover.1417985975.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Found a couple of xdr encoding problems in fs_location for referrals.  These
should fix up:
https://bugzilla.redhat.com/show_bug.cgi?id=1164055
nfs referral mount fail with "mount(2): Input/output error"

Benjamin Coddington (2):
  nfsd4: fix xdr4 inclusion of escaped char
  nfsd4: fix xdr4 count of server in fs_location4

 fs/nfsd/nfs4xdr.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

