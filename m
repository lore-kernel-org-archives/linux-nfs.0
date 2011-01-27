Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab1A0Stg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jan 2011 13:49:36 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0RInZlk006563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0RInZcP018723
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:35 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Connectathon: Remove warning from general tests
Date: Thu, 27 Jan 2011 13:49:31 -0500
Message-Id: <1296154174-13076-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Here are three approaches to removing the 
    warning: around line 47: table wider than line width

that is currently occurring in the general tests.

The first approach is to make the stat command, which read
the output time file, ignore lines it does not understand. 

The second approach was to fix the nroff.in file. It turns
out, the only I could stop that warning was to decrease the
width of the table. Through my trials and tribulations with
this, I'm beginning to believe the generating of this warning
is a bug in the groff command, since I can not find anything
wrong with the original table definition.

The third and final approach is a patch that Jeff Layton 
purposed that leaves the table width alone and adds the
"nowarn" to the global options of the table.

All three seem to do the trick but obviously we don't need
all three... I am leaning towards the first approach since
its not dependent on nroff/tbl isms... 

Steve Dickson (2):
  Make the stat command ignore lines that it is not looking for.
  Make the tbl table smaller to avoid a warning about line width

Jeff Layton (1):
  cthon04: add "nowarn" option to nroff.in tables

 general/nroff.in |    2 +-
 general/stat.c   |    9 +++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

-- 
1.7.3.3

