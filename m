Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:47433 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752075Ab2AWTyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 14:54:44 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RpPyT-0003dQ-MZ
	for linux-nfs@vger.kernel.org; Mon, 23 Jan 2012 14:54:42 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] SUNRPC: Status trace points
Date: Mon, 23 Jan 2012 14:54:39 -0500
Message-Id: <1327348480-32549-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are three more trace points that add to the trace 
points Trond  posted last week. Meaning this patch is 
dependent on Trond's patch. 

They recorded the status of binds and connections which
is useful when debugging hangs and loops. I used them
injunction with the systemtap probs in the tracepoints/ 
directory of my (unsupported) systemtap git tree:
   git://fedorapeople.org/~steved/systemtap.git
(Note, the probs I used to test Trond's trace points
are also in that directory)

Steve Dickson (1):
  SUNRPC: Adding status trace points

 include/trace/events/sunrpc.h |   45 +++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/clnt.c             |    4 +++
 2 files changed, 49 insertions(+), 0 deletions(-)

-- 
1.7.7.5

