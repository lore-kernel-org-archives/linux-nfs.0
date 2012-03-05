Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757485Ab2CETgC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 14:36:02 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q25Ja2dL029541
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 14:36:02 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q25Ja1oA027125
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 14:36:02 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] Normalized path names on umounts (take 2)
Date: Mon,  5 Mar 2012 14:36:04 -0500
Message-Id: <1330976165-19849-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a second attempted at making paths in the
device names that have multiple slashes or no slash
at all unmount-able, without breaking any APIs.

Due to the way entries are written to both the /etc/mtab
and /proc/mounts, multiple slash have to be stripped and
leading slash have to be added (when they don't exist) 
on v4 mounts. With v3 mounts this normalization can 
not occur since those entries are always in the same format.

Finally, this normalization only needs to happen
when the mtab and /proc/mounts are not the same file.

Steve Dickson (1):
  umount.nfs: normalize path names during umounts.

 utils/mount/nfsumount.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 62 insertions(+), 2 deletions(-)

