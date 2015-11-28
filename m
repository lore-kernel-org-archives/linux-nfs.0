Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34667 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbK1Ang (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Nov 2015 19:43:36 -0500
Received: by igvg19 with SMTP id g19so39619402igv.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2015 16:43:36 -0800 (PST)
Message-ID: <1448671407.21310.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client fixes for Linux 4.4
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Fri, 27 Nov 2015 19:43:27 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 1ec218373b8ebda821aec00bb156a9c94fad9cd4:

  Linux 4.4-rc2 (2015-11-22 16:45:59 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.4-2

for you to fetch changes up to 4f2e9dce0c6348a95eaa56ade9bab18572221088:

  nfs4: resend LAYOUTGET when there is a race that changes the seqid (2015-11-25 15:32:13 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 4.4

Highlights include:

Stable patches:
- Fix a NFSv4 callback identifier leak that was also causing client crashes
- Fix NFSv4 callback decoding issues when incoming requests are truncated
- Don't declare the attribute cache valid when we call nfs_update_inode with
  an empty attribute structure.
- Resend LAYOUTGET when there is a race that changes the seqid

Bugfixes:
- Fix a number of issues with the NFSv4.2 CLONE ioctl()
- Properly set NFS v4.2 NFSDBG_FACILITY
- NFSv4 referrals are broken; Cleanup FATTR4_WORD0_FS_LOCATIONS after
  decoding success
- Use sliding delay when LAYOUTGET gets NFS4ERR_DELAY
- Ensure that attrcache is revalidated after a SETATTR

----------------------------------------------------------------
Anna Schumaker (1):
      NFS: Properly set NFS v4.2 NFSDBG_FACILITY

Benjamin Coddington (2):
      nfs4: start callback_ident at idr 1
      nfs4: limit callback decoding to received bytes

Christoph Hellwig (5):
      nfs: pass on count for CLONE operations
      nfs: offer native ioctls even if CONFIG_COMPAT is set
      nfs: allow intra-file CLONE
      nfs: use btrfs ioctl defintions for clone
      nfs: reduce the amount of ifdefs for v4.2 in nfs4file.c

Jeff Layton (4):
      nfs: use sliding delay when LAYOUTGET gets NFS4ERR_DELAY
      nfs: ensure that attrcache is revalidated after a SETATTR
      nfs: if we have no valid attrs, then don't declare the attribute cache valid
      nfs4: resend LAYOUTGET when there is a race that changes the seqid

Kinglong Mee (1):
      NFS4: Cleanup FATTR4_WORD0_FS_LOCATIONS after decoding success

 fs/nfs/callback_xdr.c         |  7 +++--
 fs/nfs/inode.c                | 11 ++++++--
 fs/nfs/nfs42proc.c            |  3 ++-
 fs/nfs/nfs4client.c           |  2 +-
 fs/nfs/nfs4file.c             | 59 ++++++++++++++++++++-----------------------
 fs/nfs/nfs4proc.c             |  2 +-
 fs/nfs/nfs4xdr.c              |  1 +
 fs/nfs/pnfs.c                 | 56 ++++++++++++++++++++++------------------
 include/linux/nfs_xdr.h       |  1 +
 include/uapi/linux/nfs.h      | 11 --------
 net/sunrpc/backchannel_rqst.c |  8 ++++++
 net/sunrpc/svc.c              |  1 +
 12 files changed, 87 insertions(+), 75 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com



