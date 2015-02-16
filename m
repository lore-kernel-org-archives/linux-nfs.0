Return-Path: linux-fsdevel-owner@vger.kernel.org
Date: Mon, 16 Feb 2015 15:38:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT] nfsd bugfixes for 3.20 merge window
Message-ID: <20150216203826.GC22154@fieldses.org>
References: <20150211211725.GA28796@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211211725.GA28796@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.20

These are fixes for two bugs introduced during the merge window.

--b.

----------------------------------------------------------------
Dan Carpenter (1):
      nfsd: fix comparison in fh_fsid_match()

J. Bruce Fields (1):
      nfsd4: fix v3-less build

 fs/nfsd/nfsfh.h | 2 +-
 fs/nfsd/pnfs.h  | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)
