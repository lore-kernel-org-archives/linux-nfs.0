Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164Ab1IUSQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 14:16:58 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8LIGwDO015577
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 14:16:58 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8LIGvR1025602
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 14:16:57 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Changes in 3.1 kernel break NFS monitoring tools
Date: Wed, 21 Sep 2011 14:16:54 -0400
Message-Id: <1316629016-27740-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Both parser of nfsiostat and mountstats depend on the 
the first word in /proc/self/mountstats to be 'device'
for them to parse through all the devices. 

NFS mounts entries,  in 3.1,  no longer have start with
the word 'device'. They start with the actual device, 
which confused both set of parsing routines.

Steve Dickson (2):
  nfsiostat: Breaks on 3.1 kernels
  mountstats: Breaks on 3.1 kernels

 tools/mountstats/mountstats.py |    9 +++++++++
 tools/nfs-iostat/nfs-iostat.py |   11 +++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

-- 
1.7.6.2

