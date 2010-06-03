Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754052Ab0FCQvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:51:41 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpebQ024769
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:40 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o53Gpd8i024565
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:40 -0400
Received: from localhost.localdomain (fathat.boston.devel.redhat.com [10.16.60.125])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpcaC027759
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:39 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] mountd.nfs: Better error diagnostics for the mount command (take 3)
Date: Thu,  3 Jun 2010 12:51:36 -0400
Message-Id: <1275583898-17908-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

[I've incorporated the last few code review comments]

The following two patches add better error diagnostics when
invalid option values are given and when the network protocol
can not be determined. 

Steve Dickson (2):
  mount: silently fails when bad option values are given
  mount.nfs: silently fails when the network protocol is not found

 utils/mount/network.c   |   59 ++++++++++++++++++++++++++++++++++++----------
 utils/mount/nfsumount.c |    4 +--
 utils/mount/stropts.c   |   16 ++++++++----
 3 files changed, 58 insertions(+), 21 deletions(-)

