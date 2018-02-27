Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751633AbeB0WNU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Feb 2018 17:13:20 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8A76CC04BE01
        for <linux-nfs@vger.kernel.org>; Tue, 27 Feb 2018 22:13:20 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-98.phx2.redhat.com [10.3.116.98])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 48B4A60181
        for <linux-nfs@vger.kernel.org>; Tue, 27 Feb 2018 22:13:20 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1 V2] minorversion= is being ignored
Date: Tue, 27 Feb 2018 17:13:17 -0500
Message-Id: <20180227221318.4866-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensure "mount -t" mounts that have the 
minorversion= flag set, the given minor version is used. 

There has been some talk about deprecating the
minorversion option which it appears to be fairly 
simple in the kernel, but I think would be pretty
difficult in the userland, do to all the per-existing
scripts that used the option. 

To make the deprecation possible in the kernel, 
code was added to convert minorversion= into
vers=4.x in the string that passed to the kernel  
when the kernel is later than v3.4

Steve Dickson (1):
  mount.nfs: minorversion setting is being ignored with the -t flag

 utils/mount/network.c | 15 ++++++++++-----
 utils/mount/stropts.c | 15 +++++++++++++++
 2 files changed, 25 insertions(+), 5 deletions(-)

-- 
2.14.3

