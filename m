Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:37417 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754101Ab1KLPzs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 10:55:48 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RPFtL-0003Ia-7K
	for linux-nfs@vger.kernel.org; Sat, 12 Nov 2011 10:53:15 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Added error logging and verbosity flag (ver #2)
Date: Sat, 12 Nov 2011 10:55:44 -0500
Message-Id: <1321113346-10106-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here the second version of this patch series. In this
version, as suggested, nfsidmap now uses getopt()
to parse the command line arguments. While I was
there I so convert the timeout value to be specified
by '-t' flag instead of being the last value on the
command line.

I also prove this new debugging is helpful and needed,
because it help me find a bug in the libnfsidmap lib.

Steve Dickson (2):
  nfsidmap: Added Error Logging
  nfsidmap: Added -v and -t flags

 utils/nfsidmap/Makefile.am  |    2 +-
 utils/nfsidmap/nfsidmap.c   |   77 +++++++++++++++++++++++++++++++++---------
 utils/nfsidmap/nfsidmap.man |   26 ++++++++++----
 3 files changed, 79 insertions(+), 26 deletions(-)

-- 
1.7.7

