Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.viabit.com ([65.246.80.16]:43698 "EHLO mail2.viabit.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752015AbdHASze (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 14:55:34 -0400
Received: from localhost.localdomain (vpn1.metro-data.com [65.213.236.242])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.viabit.com (Postfix) with ESMTPSA id 3xMQW967Znz4KSw
        for <linux-nfs@vger.kernel.org>; Tue,  1 Aug 2017 14:55:33 -0400 (EDT)
From: Michael Orlitzky <michael@orlitzky.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/1] rpcbind: install the rpcbind program to sbindir.
Date: Tue,  1 Aug 2017 14:55:24 -0400
Message-Id: <20170801185525.13063-1-michael@orlitzky.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to its own man page, the rpcbind program "can only be
started by the super-user." On systems where a distinction is made, it
therefore makes sense to install rpcbind to the autotools sbindir
rather than the regular bindir where it is currently installed.

The only difference between this and the first version of the patch is
the addition of the Signed-off-by line in the commit message.

Michael Orlitzky (1):
  autotools: install rpcbind to --sbindir.

 Makefile.am                | 3 ++-
 configure.ac               | 6 +++---
 systemd/rpcbind.service.in | 2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

-- 
2.13.0

