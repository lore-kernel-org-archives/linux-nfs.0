Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53080 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab1HPLyH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 07:54:07 -0400
Subject: [PATCH 0/2] 32/64 bit llseek hashes (v3)
To: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: bfields@fieldses.org, tytso@mit.edu, bernd.schubert@fastmail.fm,
        hch@infradead.org, adilger@whamcloud.com, yong.fan@whamcloud.com,
        linux-fsdevel@vger.kernel.org
Date: Tue, 16 Aug 2011 13:54:04 +0200
Message-ID: <20110816115404.1810393.47239.stgit@localhost.localdomain>
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

The following series adds two new f_mode flags to tell ext4
to use 32-bit or 64-bit hash values for llseek() calls.
These flags can then used by network file systems, such as NFS, to
request 32-bit or 64-bit offsets (hashes).

Version 3:
- remove patch "RFC: Remove check for a 32-bit cookie in nfsd4_readdir()",
  I think Bruce wanted to take it seperately as bug fix. It should be applied
  before applying the remaining NFS patches, as without it NFSv4 will always
  fail with the new 64-bit ext4 seek hashes.
- split "nfsd: vfs_llseek() with 32 or 64 bit offsets (hashes)" into two
  two separate patches as suggested by Bruce, one patch to rename 
  'access' to 'may_flags'. And the remainder of the original patch to set 
  FMODE_32BITHASH/FMODE_64BITHASH flags and to introduce the new 
  NFSD_MAY_64BIT_COOKIE flag

Version 2:
- use f_mode instead of O_* flags and also in a separate patch
- introduce EXT4_HTREE_EOF_32BIT and EXT4_HTREE_EOF_64BIT
- fix SEEK_END in ext4_dir_llseek()
- set f_mode flags in NFS code as early as possible and introduce a new
  NFSD_MAY_64BIT_COOKIE flag for that

--
Bernd Schubert
Fraunhofer ITWM

