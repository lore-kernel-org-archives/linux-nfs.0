Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754412AbaIVTUM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 15:20:12 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8MJKCFf013639
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 15:20:12 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials (v3)
Date: Mon, 22 Sep 2014 15:20:06 -0400
Message-Id: <1411413608-16462-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gssproxy(8) daemon will now be used to manage the GSSAPI 
credentials on the server.  

The nfs-server systemd script will now start gssproxy and
the building/installing of rpc.svcgssd is now off by default.

Steve Dickson (2):
  nfs-service: Added the starting of gssproxy
  rpc.svcgssd: the build of rpc.svcgssd is off by default

 configure.ac               | 23 +++++++++++++++++++----
 systemd/nfs-server.service |  5 +++--
 utils/gssd/Makefile.am     | 11 +++++++++--
 3 files changed, 31 insertions(+), 8 deletions(-)

-- 
1.9.3

