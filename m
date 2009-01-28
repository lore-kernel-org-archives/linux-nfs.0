From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Support IPv6 in umount.nfs command
Date: Wed, 28 Jan 2009 18:07:32 -0500
Message-ID: <20090128225938.21484.82096.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:23758 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbZA1XJJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 18:09:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

The first patch in this series is a simple update to .gitignore.

The following patches implement support for IPv6 addresses in the
umount.nfs command.

I think it would be prudent to stop after this set, and let the
extensive changes I've submitted so far soak a little bit.  These
probably won't see wide-ranging use until after the next release of
nfs-utils, I'm guessing.

Given the problems that arose after the last nfs-utils release, I
think this might be a good stopping point until after the next
nfs-utils release.  By then, I might even have full support completed
for IPv6 in rpc.statd and sm-notify.

---

Chuck Lever (4):
      umount command: remove do_nfs_umount23 function
      umount.nfs command: Support AF_INET6 server addresses
      umount.nfs command: Add an AF_INET6-capable version of nfs_call_unmount()
      nfs-utils: git should ignore cscope.* files


 .gitignore              |    2 +
 utils/mount/network.c   |   53 ++++++++++++++++
 utils/mount/network.h   |    4 +
 utils/mount/nfsumount.c |  158 ++++++++++++++++++++++++-----------------------
 4 files changed, 138 insertions(+), 79 deletions(-)

-- 
Chuck Lever < chuck [dot] lever [at] oracle [dot] com >
