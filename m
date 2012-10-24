Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161028Ab2JXSLd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:33 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBWRd016382
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:32 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSC020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:32 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] libgssglue clean up.
Date: Wed, 24 Oct 2012 14:08:39 -0400
Message-Id: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches, including the ones Yao Zhao posted a while back,
remove a number of different types of warnings through out the 
code.

Steve Dickson (2):
  Fixed warnings in src/g_mit_krb5_mech.c
  Fixed warnings in src/g_unseal.c and src/g_verify.c

Yao Zhao (3):
  Fixed warnings in src/g_canon_name.c
  Fixed warnings in src/g_initialize.c
  Fixed warnings in src/g_inq_cred.c

 src/g_canon_name.c    | 16 +++++++++++-----
 src/g_initialize.c    |  2 ++
 src/g_inq_cred.c      |  6 ++++--
 src/g_mit_krb5_mech.c |  1 -
 src/g_unseal.c        |  2 +-
 src/g_verify.c        |  2 +-
 src/mglueP.h          |  4 ++--
 7 files changed, 21 insertions(+), 12 deletions(-)

-- 
1.7.11.7

