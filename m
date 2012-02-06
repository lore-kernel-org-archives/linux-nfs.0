Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:34221 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755172Ab2BFPIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 10:08:23 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/2] SUNRPC: Added Tracing Points
Date: Mon,  6 Feb 2012 10:08:06 -0500
Message-Id: <1328540888-30109-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Resent with correct email addresses]

This series combines the trace points that Trond
posted, than now handle strings properly and the
trace points I posted, in which I integrated the 
review comments.

All these trace point were tested/enable through the
debugfs interface and being called from systemtab 
probs.

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

-- 
1.7.7.5

