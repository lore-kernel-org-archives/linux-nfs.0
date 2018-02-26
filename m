Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbeBZTPo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Feb 2018 14:15:44 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BD5D87FEBF
        for <linux-nfs@vger.kernel.org>; Mon, 26 Feb 2018 19:15:44 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-20.phx2.redhat.com [10.3.116.20])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7962860C8D
        for <linux-nfs@vger.kernel.org>; Mon, 26 Feb 2018 19:15:44 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] minorversion= is being ignored
Date: Mon, 26 Feb 2018 14:15:41 -0500
Message-Id: <20180226191542.31447-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch ensure "mount -t" mounts that have the 
minorversion= flag set, the given minor version
is used. 

There has been some talk about deprecating the
minorversion option which it appears to be fairly 
simple in the kernel, but I think would be pretty
difficult in the userland, do to all the per-existing
scripts that used the option. 

To make the deprecation possible in the kernel, 
code was added to convert minorversion= into
vers=4.x in the string that passed to the kernel.  

Steve Dickson (1):
  mount.nfs: minorversion setting is being ignored with -t flag

 utils/mount/network.c | 15 ++++++++++-----
 utils/mount/stropts.c | 14 ++++++++++++++
 2 files changed, 24 insertions(+), 5 deletions(-)

-- 
2.14.3

