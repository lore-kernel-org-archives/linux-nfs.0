Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:7058 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754Ab3AKSFa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2013 13:05:30 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: linux-kernel <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull one SUNRPC client bugfix
Date: Fri, 11 Jan 2013 18:05:28 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91199BA38@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following changes since commit d287b8750e47c1702dab0e37ac11012bb751ece0:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs (2013-01-07 09:41:20 -0800)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.8-3

for you to fetch changes up to 87ed50036b866db2ec2ba16b2a7aec4a2b0b7c39:

  SUNRPC: Ensure we release the socket write lock if the rpc+AF8-task exits early (2013-01-08 14:30:43 -0500)

----------------------------------------------------------------
NFS client bugfixe for Linux 3.8

- Fix a socket lock leak in net/sunrpc/xprt.c

----------------------------------------------------------------
Trond Myklebust (1):
      SUNRPC: Ensure we release the socket write lock if the rpc+AF8-task exits early

 net/sunrpc/sched.c +AHw-  3 +---
 net/sunrpc/xprt.c  +AHw- 12 +-+-+-+-+-+-+-+-+-+---
 2 files changed, 11 insertions(+-), 4 deletions(-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
