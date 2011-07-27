Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:41973 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab1G0LCr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 07:02:47 -0400
Subject: [PATCH 0/3] 32/64 bit llseek hashes
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        adilger@whamcloud.com, tytso@mit.edu
Date: Wed, 27 Jul 2011 13:02:44 +0200
Message-ID: <20110727110148.204979.49551.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With the ext3/ext4 directory index implementation hashes are used to specify
offsets for llseek(). For compatibility with NFSv2 and 32-bit user space
on 64-bit systems (kernel space) ext3/ext4 currently only return 32-bit 
hashes and therefore the probability of hash collisions for larger directories
is rather high. As recently reported on the NFS mailing list that theoretical
problem also happens on real systems:
http://comments.gmane.org/gmane.linux.nfs/40863

The following series adds two new open flags to tell ext4
to to 32-bit or 64-bit hash values for llseek() calls.
These flags are then used by NFS to use 32-bit (NFSv2) or 64-bit
offsets (hashes in case of ext3/ext4) for readdir and seekdir.
User space does not need to specify these flags, but usually the check
for is_32bit_api() should be sufficient.

---

Bernd Schubert (2):
      Remove check for a 32-bit cookie in nfsd4_readdir()
      nfsd: vfs_llseek() with O_32BITHASH or O_64BITHASH

Fan Yong (1):
      Return 32/64-bit dir name hash according to usage type


 fs/ext4/dir.c               |  160 ++++++++++++++++++++++++++++++++++---------
 fs/fcntl.c                  |    5 +
 fs/nfsd/nfs4proc.c          |    2 -
 fs/nfsd/vfs.c               |    6 ++
 include/asm-generic/fcntl.h |    9 ++
 5 files changed, 145 insertions(+), 37 deletions(-)

-- 
Bernd Schubert
