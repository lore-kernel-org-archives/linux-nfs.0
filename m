Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51955 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964912Ab3DJRGy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 13:06:54 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] One line typo fix
Date: Wed, 10 Apr 2013 17:06:45 +0000
Message-ID: <1365613610.8465.16.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

I suddenly noticed that a one-line issue that I _thought_ I had fixed
with the nfs41_walk_client_list patch was apparently still there in the
pull request I sent earlier today. I'm very sorry for not catching that
in time.

The following changes since commit fa332941c0c7c00e3420078268b7558d0ef792b5:

  NFSv4: Fix another potential state manager deadlock (2013-04-09 13:19:35 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.9-5

for you to fetch changes up to eb04e0ac198cec3bab407ad220438dfa65c19c67:

  NFSv4: Doh! Typo in the fix to nfs41_walk_client_list (2013-04-10 12:57:29 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.9

- Fix a brain fart in nfs41_walk_client_list

----------------------------------------------------------------
Trond Myklebust (1):
      NFSv4: Doh! Typo in the fix to nfs41_walk_client_list

 fs/nfs/nfs4client.c | 1 +
 1 file changed, 1 insertion(+)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
