Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33308 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbcDAPme (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Apr 2016 11:42:34 -0400
Received: by mail-io0-f171.google.com with SMTP id a129so147806148ioe.0
        for <linux-nfs@vger.kernel.org>; Fri, 01 Apr 2016 08:42:34 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/2 vers 2] FlexFiles: too many bytes w/ direct+aio retried read
Date: Fri,  1 Apr 2016 11:42:27 -0400
Message-Id: <1459525349-6100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

vers 2 fixes unused var found by buildbot.

Patch 1 fixes an issue seen when using libaio with directio where if a read
is retried (ie due to recalled layout) we return too many bytes.
Specifically, we returned a multiple of the read size.

To reproduce, run fio with ioengine=libaio and direct=1, then revoke the
active layout. This should hit pretty easily.

Patch 2 should help notice similar issues elsewhere.


Weston Andros Adamson (2):
  pnfs: set NFS_IOHDR_REDO in pnfs_read_resend_pnfs
  nfs: add debug to directio "good_bytes" counting

 fs/nfs/direct.c |  7 +++++--
 fs/nfs/pnfs.c   | 14 ++++++++------
 fs/nfs/pnfs.h   |  2 +-
 3 files changed, 14 insertions(+), 9 deletions(-)

-- 
2.6.4 (Apple Git-63)

