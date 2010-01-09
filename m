From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Fri, 08 Jan 2010 19:56:24 -0500
Message-ID: <20100109005624.7473.33215.stgit@localhost.localdomain>
References: <1262913974.2659.101.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351Ab0AIBGs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 20:06:48 -0500
In-Reply-To: <1262913974.2659.101.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How about something like the following. I chose to wrap the call to
do_mmap_pgoff() instead of making a special ->pre_mmap(), since that
seems more consistent with the way we handle ->read() and ->write().

I also left sys_uselib() and do_execve() to rely on revalidate at
open(), since executables and libraries really are not ever expected to
change while open.

Cheers
  Trond

---

Trond Myklebust (2):
      NFS: Fix a potential deadlock in nfs_file_mmap()
      VFS: Add a mmap_file() callback to struct file_operations


 fs/nfs/file.c      |   28 ++++++++++++++++++++++------
 fs/nfs/inode.c     |    4 ++++
 include/linux/fs.h |    5 +++++
 mm/filemap.c       |   23 +++++++++++++++++++++++
 mm/mmap.c          |   11 ++++++++---
 mm/nommu.c         |   11 ++++++++---
 6 files changed, 70 insertions(+), 12 deletions(-)

-- 
Signature
