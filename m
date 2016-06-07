Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32937 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbcFGXfS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 19:35:18 -0400
Received: by mail-pf0-f179.google.com with SMTP id y124so22747878pfy.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 16:35:17 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC 0/2] Sharing flex file XDR encoding between client and server
Date: Tue,  7 Jun 2016 16:34:44 -0700
Message-Id: <1465342486-21750-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This builds on my prior change set for the flex file server.

I'm not too hot on putting this much code in a header, but
I can't think of a cleaner way without leaking too much
between the client and server.

Any guidance on how this is typically approached?

Thanks,
Tom


Tom Haynes (2):
  nfs: Encoding a netaddr is common to client and server
  nfsd: Encode a netaddr correctly

 fs/nfs/flexfilelayout/flexfilelayout.c |  93 +-----------------------------
 fs/nfs/flexfilelayout/flexfilelayout.h |   5 +-
 fs/nfsd/flexfilelayout.c               |  26 +--------
 fs/nfsd/flexfilelayoutxdr.c            |  34 +++++------
 fs/nfsd/flexfilelayoutxdr.h            |  15 +----
 include/linux/nfs4_ff.h                | 100 +++++++++++++++++++++++++++++++++
 6 files changed, 120 insertions(+), 153 deletions(-)
 create mode 100644 include/linux/nfs4_ff.h

-- 
2.5.5

