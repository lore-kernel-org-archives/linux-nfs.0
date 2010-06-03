From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 0/2] mountd.nfs: Better error diagnostics for the mount command (take 2)
Date: Thu,  3 Jun 2010 09:02:12 -0400
Message-ID: <1275570134-24864-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:57825 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752685Ab0FCNCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 09:02:15 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1OKA3q-0004JY-6u
	for linux-nfs@vger.kernel.org; Thu, 03 Jun 2010 09:02:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[I incorporated the comments from the code review of the 
previous patches]

The following two patches add better error diagnostics when
invalid protocol version are given and when the network protocol
can not be determined. 

Steve Dickson (2):
  mount: silently fails when bad option values are given
  mount.nfs: silently fails when the network protocol is not found

 utils/mount/network.c   |   39 ++++++++++++++++++++++++++++++++++-----
 utils/mount/nfsumount.c |    4 +---
 utils/mount/stropts.c   |   16 +++++++++++-----
 3 files changed, 46 insertions(+), 13 deletions(-)

