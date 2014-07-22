Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:33616 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323AbaGVQtv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 12:49:51 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so6792495qac.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 09:49:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH 0/4] nfsd: don't let nfs4_file pin down the inode when it has no open state
Date: Tue, 22 Jul 2014 12:49:40 -0400
Message-Id: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a port of the patches that Trond sent last night onto the
current tip of Bruce's for-3.17 branch. It basically changes how
nfs4_file objects are hashed. Instead of using the inode pointer (and
pinning down an inode in the process), it uses the filehandle. This
allows us to avoid taking an inode reference directly for the nfs4_file.
It now only takes them indirectly by virtue of struct file objects in
the fi_fds array.

If this looks good, I'll resend the unmerged delegation overhaul
patches, rebased on top of this series.

Trond Myklebust (4):
  nfsd: Store the filehandle with the struct nfs4_file
  nfsd: Use the filehandle to look up the struct nfs4_file instead of
    inode
  nfsd: nfs4_check_fh - make it actually check the filehandle
  nfsd: Do not let nfs4_file pin the struct inode

 fs/nfsd/nfs4state.c | 68 +++++++++++++++++++++++++++++++----------------------
 fs/nfsd/state.h     |  3 ++-
 2 files changed, 42 insertions(+), 29 deletions(-)

-- 
1.9.3

