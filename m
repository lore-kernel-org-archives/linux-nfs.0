Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34353 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbLHMX5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 07:23:57 -0500
Received: by qkdp187 with SMTP id p187so25846235qkd.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Dec 2015 04:23:56 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [RFC PATCH 0/2] nfsd: clean up CB_LAYOUTRECALL handling
Date: Tue,  8 Dec 2015 07:23:46 -0500
Message-Id: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a proposal that should follow the broad outlines of what HCH
was suggesting for CB_LAYOUTRECALL. It changes the code to treat 0
and NFS4ERR_DELAY returns equivalently, and also implements a scheme
to give up on the client after two lease periods.

Note that this is _not_ tested, since I don't have a pnfs test rig on
which to test this.

Jeff Layton (2):
  nfsd: don't hold ls_mutex across a layout recall
  nfsd: give up on CB_LAYOUTRECALLs after two lease periods

 fs/nfsd/nfs4layouts.c | 37 ++++++++++++++++++++++++++-----------
 1 file changed, 26 insertions(+), 11 deletions(-)

-- 
2.5.0

