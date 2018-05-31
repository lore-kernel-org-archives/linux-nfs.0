Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:57344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755443AbeEaPz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 11:55:27 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1D6DEEB6F3
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:27 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DEC3F39DDB
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:26 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Fixing a couple warnings
Date: Thu, 31 May 2018 11:55:23 -0400
Message-Id: <20180531155525.60495-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are a couple warnings that I started getting
when I compiled on a freshly install Fedora 28.

The first patch turns off the compiling of rpcgen
by default. The command produces code that cause
a number of warnings which are now errors. 

The old glibc rpcgen, which is now in the 
rpcsvc-proto package, does a much better job
of not creating warnings.

The second patch fixes a couple warnings I 
was not seeing.

Steve Dickson (1):
  rpcgen: Only compile the command when configured.

gabriele balducci (1):
  Fixed format overflow warnings in mountd and nfsd

 configure.ac          | 2 +-
 utils/mountd/mountd.c | 2 +-
 utils/nfsd/nfsd.c     | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

-- 
2.17.0

