Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754600Ab2JIVUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 17:20:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1: pNFS has no business touching the slot table waitq...
Date: Tue,  9 Oct 2012 17:20:07 -0400
Message-Id: <1349817608-4730-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Hi Trond:

How about this?

I tested this patch against the rpc_wake_up version - no difference in run
time for DS disconnect.

I have not yet tested DS invalid layout, but since
the invalid layout does not trigger a deviceid invalidation, each call using
the layout will go through filelayout_async_handle_error, free the slot, and
wake up the next task on the ds session fore channel slot table waitq, and
the filelayout_read/write_prepare routines do not reset to the MDS.

-->Andy

Andy Adamson (1):
  NFSv4.1	do not wake up all tasks on data server reset to MDS

 fs/nfs/internal.h       |    1 +
 fs/nfs/nfs4filelayout.c |    5 ++---
 fs/nfs/nfs4proc.c       |   18 +++++++++++++-----
 3 files changed, 16 insertions(+), 8 deletions(-)

-- 
1.7.7.6

