Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575AbaIWQVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 12:21:45 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGLifN019842
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:21:45 -0400
Received: from smallhat.boston.devel.redhat.com (vpn-55-23.rdu2.redhat.com [10.10.55.23])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8NGLhMt027727
	for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 12:21:44 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials (v4)
Date: Tue, 23 Sep 2014 12:21:39 -0400
Message-Id: <1411489301-28991-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When gssproxy(8) daemon is installed, that daemon will be used
to manage the GSSAPI credentials on the server.  

The nfs-server unit will start gssproxy when it exists 
otherwise rpc.svcgssd will be started as usual.

Also, a configure switch was added to disable the building 
of rpc.svcgssd. 

Steve Dickson (2):
  rpc.svcgssd: Add a configure switch to disable building the daemon
  nfs-service: Added gssproxy support

 configure.ac               | 23 +++++++++++++++++++----
 systemd/nfs-server.service |  5 +++--
 utils/gssd/Makefile.am     | 11 +++++++++--
 3 files changed, 31 insertions(+), 8 deletions(-)

-- 
1.9.3

