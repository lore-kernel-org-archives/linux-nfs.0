Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbaISRKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 13:10:25 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JHAPXV011885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 13:10:25 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials (v2)
Date: Fri, 19 Sep 2014 13:10:19 -0400
Message-Id: <1411146621-18797-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gssproxy(8) daemon will now be used to manage the GSSAPI 
credentials on the server.  

The nfs-server systemd script will now start gssproxy and
the building/installing of rpc.svcgssd is now off by
default.

Steve Dickson (2):
  nfs-server: Replace rpc.svcgssd with gssproxy in systemd script
  rpc.svcgssd: the build of rpc.svcgssd is off by default

 configure.ac               | 23 +++++++++++++++++++----
 systemd/nfs-server.service |  4 ++--
 utils/gssd/Makefile.am     | 11 +++++++++--
 3 files changed, 30 insertions(+), 8 deletions(-)

-- 
1.9.3

