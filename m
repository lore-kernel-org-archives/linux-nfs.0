Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756111Ab2JXPvy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 11:51:54 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OFpsG2022343
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 11:51:54 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OFprVp026851
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 11:51:53 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] libgssglue cleanup
Date: Wed, 24 Oct 2012 11:48:59 -0400
Message-Id: <1351093741-7663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following two patches update how libgssglue is 
built and git ignore things that are a result 
of that build.

Steve Dickson (2):
  Added libtoolize call to autogen.sh
  Git ignored things that are generated during the build

 .gitignore   |    26 +
 Makefile.am  |     2 +
 autogen.sh   |     2 +-
 configure.in |     1 +
 ltmain.sh    | 14491 +++++++++++++++++++++++++++++++++++----------------------
 5 files changed, 8888 insertions(+), 5634 deletions(-)
 create mode 100644 .gitignore

-- 
1.7.11.7

