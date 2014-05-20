Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27768 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbaETSI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 00/12] PNFS Read and Write Cleanups
Date: Tue, 20 May 2014 14:08:07 -0400
Message-ID: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a lot of duplicate code in pnfs.c that can be cleaned up to
share more code.  This patch set goes through each function one at a
time and merges read and write code together wherever possible.  In the
end I'm passing around a few function pointers.  Would it be better to
use a function pointer struct instead?

These patches still need a lot of testing and are not ready for merge
yet (hence the RFC).  I just wanted to send out a preview of the changes
I've made so far.

Questions, comments and thoughts are appreciated!

Anna


Anna Schumaker (12):
  nfs: Create a common pnfs_pageio_reset_mds() function
  nfs: Create a common pnfs_generic_pg_init() function
  nfs: Create a common pnfs_ld_handle_rw_error() function
  nfs: Create a common pnfs_ld_rw_done()
  nfs: Create a common pnfs_through_mds() function
  nfs: merge pnfs_try_to_write_data() and pnfs_do_write()
  nfs: merge pnfs_try_to_read_data() and pnfs_do_read()
  nfs: create a common pnfs_do_rw() function
  nfs: create a common pnfs_pgiohdr_free function
  nfs: Split up generic_pg_pgios
  nfs: pnfs can use nfs_generic_pgios_common() too!
  nfs: Create a common pnfs_generic_rwpages() function

 fs/nfs/blocklayout/blocklayout.c |   4 +-
 fs/nfs/internal.h                |   6 +-
 fs/nfs/nfs4filelayout.c          |   4 +-
 fs/nfs/pagelist.c                |  25 +++-
 fs/nfs/pnfs.c                    | 297 ++++++++++++++-------------------------
 fs/nfs/pnfs.h                    |   1 +
 fs/nfs/read.c                    |   7 -
 fs/nfs/write.c                   |   8 --
 8 files changed, 138 insertions(+), 214 deletions(-)

-- 
1.9.2

