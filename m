Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755176Ab2AXUB5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 15:01:57 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0OK1vAi017975
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 15:01:57 -0500
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q0OK1unv023893
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2012 15:01:57 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] SUNRPC: Added Tracing Points
Date: Tue, 24 Jan 2012 15:51:45 -0500
Message-Id: <1327438307-2910-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series combines the trace points that Trond
posted, than now handle strings properly, and the
trace points I posted, in which I integrated the 
review comments.

All these trace point were tested/enable through the
debugfs interface as well as being called from a 
systemtab prob.

Steve Dickson (1):
  SUNRPC: Adding status trace points

Trond Myklebust (1):
  SUNRPC: Add trace events to the sunrpc subsystem

 include/linux/sunrpc/sched.h  |    2 +-
 include/trace/events/sunrpc.h |  177 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    6 +-
 net/sunrpc/sched.c            |   12 +++
 4 files changed, 195 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/events/sunrpc.h

