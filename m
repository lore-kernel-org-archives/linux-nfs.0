From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Failure to fallback to nfsd-v3 (?)
Date: Sun, 07 Feb 2010 12:32:04 +0900
Message-ID: <87pr4h67rf.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've recently noticed I couldn't mount nfs on 2.6.33-rc6. The environment is

	server (nfsd-v3, 2.6.33-rc6) <-> client (2.6.32.7, nfs-utils 1.2.1)

And mount command is

	# mount server:/path /mntpoint

(i.e. without any options. If I specified "vers=3" option, it works).

With some debugging, it seems to change of the error code on nfsd - the
log of failure is the following.

nfsd_dispatch: vers 4 proc 0
nfsd_dispatch: vers 4 proc 1
nfsv4 compound op #1/3: 24 (OP_PUTROOTFH)
nfsv4 compound op ffff88012d9e10c0 opcnt 3 #1: 24: status 30000
nfsv4 compound returned 30000
nfsd: Dropping request; may be revisited later
found domain *.xxx.xx
found fsidtype 1
found fsid length 4
Path seems to be <>
nfsd_dispatch: vers 4 proc 1
nfsv4 compound op #1/3: 24 (OP_PUTROOTFH)
nfsv4 compound op ffff88012dab6228 opcnt 3 #1: 24: status 10006
nfsv4 compound returned 10006

On the older kernel (2.6.32.7), it seems to fallback to nfsv3,

nfsd_dispatch: vers 4 proc 0
nfsd_dispatch: vers 4 proc 1
nfsv4 compound op #1/3: 24 (OP_PUTROOTFH)
nfsv4 compound op d9c04850 opcnt 3 #1: 24: status 2
nfsv4 compound returned 2
nfsd_dispatch: vers 3 proc 0
[...]


And the following commit seems to change the behavior.

[nfsd4: fix error return when pseudoroot missing]
f39bde24b275ddc45df1ed835725b609e178c7a0

Well, anyway, is this a expected behavior change, or something bug?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
