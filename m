Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939060AbdD0U03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Apr 2017 16:26:29 -0400
Date: Thu, 27 Apr 2017 16:26:28 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd fixes for 4.11
Message-ID: <20170427202628.GA8989@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull knfsd bugfixes for 4.11 from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.11-3

Thanks to Ari Kauppi and Tuomas Haanpää at Synopsis for spotting bugs in
our NFSv2/v3 xdr code that could crash the server or expose memory.

--b.

J. Bruce Fields (3):
      nfsd: check for oversized NFSv2/v3 arguments
      nfsd4: minor NFSv2/v3 write decoding cleanup
      nfsd: stricter decoding of write-like NFSv2/v3 ops

 fs/nfsd/nfs3xdr.c | 13 +++++++++----
 fs/nfsd/nfssvc.c  | 36 ++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsxdr.c  | 10 ++++++----
 3 files changed, 51 insertions(+), 8 deletions(-)
