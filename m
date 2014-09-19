Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbaISMvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 08:51:47 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JCplSd024183
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 08:51:47 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
Date: Fri, 19 Sep 2014 08:51:41 -0400
Message-Id: <1411131103-17254-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gssproxy(8) daemon is now how the managing of GSSAPI 
credentials should be done. 

These to patches has the nfs-server systemd script start 
gssproxy instead of rpc.svcgssd and removes the building 
and installation of rpc.svcgssd.

For now I'm leaving the source files... Just in case... ;-)

Steve Dickson (2):
  nfs-server: Replace rpc.svcgssd with gssproxy
  svcgssd: Remove rules from the Makefile.am

 systemd/nfs-server.service  |  4 ++--
 systemd/rpc-svcgssd.service | 19 -------------------
 utils/gssd/Makefile.am      | 25 ++-----------------------
 3 files changed, 4 insertions(+), 44 deletions(-)
 delete mode 100644 systemd/rpc-svcgssd.service

-- 
1.9.3

