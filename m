Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:65416 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab2HHCD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 22:03:26 -0400
Received: by pbbrr13 with SMTP id rr13so617318pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 19:03:26 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: bharrosh@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 0/3] NFS41: optimize layoutget
Date: Wed,  8 Aug 2012 10:03:09 +0800
Message-Id: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patches optimize layoutget size by sending real IO size instead
of just a small length in each layoutget. It helps server to do better
decisions about layout segment size and thus helps reduce layoutget
operation numbers a lot.

Boaz please see if you like the behavior in generic layout. If not, I can
make it block layout only.

Thanks,
Tao

Peng Tao (3):
  NFS: track direct IO left bytes
  NFS41: send real write size in layoutget
  NFS41: send real read size in layoutget for DIO

 fs/nfs/direct.c   |   12 +++++++++
 fs/nfs/internal.h |    1 +
 fs/nfs/pnfs.c     |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 76 insertions(+), 3 deletions(-)

