Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:47352 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757109Ab0DPPKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 11:10:24 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O2nBV-00018J-Lw
	for linux-nfs@vger.kernel.org; Fri, 16 Apr 2010 11:10:22 -0400
From: Steve Dickson <steved@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 0/3] Introduce two new mount stats commands
Date: Fri, 16 Apr 2010 11:10:18 -0400
Message-Id: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These patches install the mountstats and nfsiostat commands
as well as creates and installed their man pages. 

Steve Dickson (3):
  Introduce man page for the mountstats command
  Introduce man page for the nfsiostats command
  Add autoconf support for mountstats and nfsiostats

 configure.ac                    |    2 +
 tools/Makefile.am               |    2 +-
 tools/mountstats/Makefile.am    |   13 +++++++
 tools/mountstats/mountstats.man |   32 ++++++++++++++++++
 tools/nfs-iostat/Makefile.am    |   13 +++++++
 tools/nfs-iostat/nfsiostat.man  |   70 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 131 insertions(+), 1 deletions(-)
 create mode 100644 tools/mountstats/Makefile.am
 create mode 100644 tools/mountstats/mountstats.man
 create mode 100644 tools/nfs-iostat/Makefile.am
 create mode 100644 tools/nfs-iostat/nfsiostat.man

