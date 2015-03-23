Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33814 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbbCWOxz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 10:53:55 -0400
Received: by ykfc206 with SMTP id c206so72975703ykf.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 07:53:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsd: fix use-after-free oops in v4.0 (and some other minor cleanups)
Date: Mon, 23 Mar 2015 10:53:41 -0400
Message-Id: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

After staring at this code for a _long_ time, I think I've finally found
the source of the use-after-free oops that HCH spotted. The first patch
in this series should fix that.  The other two patches are just cleanups
that I generated while staring at the code.

The first one obviously needs to go into v4.0 (and stable) ASAP. The
other two can wait for v4.1.

Jeff Layton (3):
  nfsd: return correct openowner when there is a race to put one in the
    hash
  nfsd: remove bogus setting of status in nfsd4_process_open2
  nfsd: remove unused status arg to nfsd4_cleanup_open_state

 fs/nfsd/nfs4proc.c  | 2 +-
 fs/nfsd/nfs4state.c | 5 ++---
 fs/nfsd/xdr4.h      | 2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

-- 
2.1.0

