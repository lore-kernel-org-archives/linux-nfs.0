Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:45968 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934873Ab2JXOa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 10:30:27 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so598690vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 07:30:26 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/4] nfsd: add a usermodehelper upcall for client id tracking
Date: Wed, 24 Oct 2012 10:30:14 -0400
Message-Id: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the set with the same title that I sent on October
3rd. The main difference is the addition of a printk warning for people
that are using the nfsdcld upcall, and some minor bugfixes and renaming
of functions for consistency.

I'd like to see this go into 3.8 if possible.

Jeff Layton (4):
  nfsd: add a usermodehelper upcall for NFSv4 client ID tracking
  nfsd: change heuristic for selecting the client_tracking_ops
  nfsd: pass info about the legacy recoverydir in environment variables
  nfsd: warn about impending removal of nfsdcld upcall

 fs/nfsd/nfs4recover.c | 247 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 237 insertions(+), 10 deletions(-)

-- 
1.7.11.7

