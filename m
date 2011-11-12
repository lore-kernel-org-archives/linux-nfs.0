Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:56220 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752981Ab1KLPxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:53:39 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFrG-0003ID-IX
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:51:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Enable the in-kernel id mapping to be on by default (ver #2)
Date: Sat, 12 Nov 2011 10:53:35 -0500
Message-Id: <1321113217-10018-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In this version I updated idmapper.txt to specify the 
timeout with the '-k' flag.

Steve Dickson (2):
  Enable the in-kernel ID mapping upcall mechanism
  idmapper.txt: Fix the upcall binary name.

 Documentation/filesystems/nfs/idmapper.txt |   26 +++++++++++++-------------
 fs/nfs/Kconfig                             |   10 ++--------
 2 files changed, 15 insertions(+), 21 deletions(-)

-- 
1.7.7

