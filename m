Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:47793 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932847AbaGWURs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 16:17:48 -0400
Received: by mail-qa0-f44.google.com with SMTP id f12so1870657qad.17
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 13:17:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 0/4] nfsd: don't let nfs4_file pin down the inode when it has no open state
Date: Wed, 23 Jul 2014 16:17:37 -0400
Message-Id: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- eliminate the st_inode field from struct nfs4_ol_stateid

This is a port of the patches that Trond sent the other day onto the
current tip of Bruce's for-3.17 branch. It basically changes how
nfs4_file objects are hashed. Instead of using the inode pointer (and
pinning down an inode in the process), it uses the filehandle. This
allows us to avoid taking an inode reference directly for the nfs4_file.
With this, they're only taken by virtue of the files in the fi_fds
array.

Jeff Layton (1):
  nfsd: Do not let nfs4_file pin the struct inode

Trond Myklebust (3):
  nfsd: Store the filehandle with the struct nfs4_file
  nfsd: Use the filehandle to look up the struct nfs4_file instead of
    inode
  nfsd: nfs4_check_fh - make it actually check the filehandle

 fs/nfsd/nfs4state.c | 86 +++++++++++++++++++++++++++++++++--------------------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 54 insertions(+), 34 deletions(-)

-- 
1.9.3

