Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45926 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdAJQ7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jan 2017 11:59:50 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F02CEC04B95E
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2017 16:59:50 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id v0AGxoKP005249
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jan 2017 11:59:50 -0500
From: Steve Dickson <SteveD@redhat.com>
Subject: ANNOUNCE: libnfsidmap-0.27 release.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <eb6e41f7-39d4-92eb-efe9-b0cd807c6451@RedHat.com>
Date: Tue, 10 Jan 2017 11:59:50 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The majority in this release is bug fixes and clean up
as well as a couple features like:
  * Add options to aid id mapping in multi domain environments
  * Query DNS for the the NFSv4 domain

The tarballs can be found at
  https://fedorapeople.org/~steved/libnfsidmap/0.27/

The change log is at 
   https://fedorapeople.org/~steved/libnfsidmap/libnfsidmap/0.27/0.27-Changelog

The git tree is at:
  git://linux-nfs.org/~steved/libnfsidmap
  
Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
