Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041AbaJMRGW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 13:06:22 -0400
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
cc: dhowells@redhat.com, rob.jones@codethink.co.uk, manuel.schoelling@gmx.de,
        linux-cachefs@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [GIT PULL] FS-Cache: Two fixes and a cleanup
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 13 Oct 2014 18:06:07 +0100
Message-ID: <24210.1413219967@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Can you pull this please?  There are three commits: two fixes for bugs in
CacheFiles and a cleanup in FS-Cache.

David
---
The following changes since commit fe82dcec644244676d55a1384c958d5f67979adb:

  Linux 3.17-rc7 (2014-09-28 14:29:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-fixes-20141013

for you to fetch changes up to d5d962265d99088ce96480db3e61358d7170e24c:

  fs/fscache/object-list.c: use __seq_open_private() (2014-10-13 17:52:21 +0100)

----------------------------------------------------------------
FS-Cache fixes

----------------------------------------------------------------
David Howells (2):
      CacheFiles: Handle object being killed before being set up
      CacheFiles: Fix incorrect test for in-memory object collision

Rob Jones (1):
      fs/fscache/object-list.c: use __seq_open_private()

 fs/cachefiles/interface.c | 33 ++++++++++++++++++++-------------
 fs/cachefiles/namei.c     |  2 +-
 fs/fscache/object-list.c  | 16 ++--------------
 3 files changed, 23 insertions(+), 28 deletions(-)
