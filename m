From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] nfs-utils: add IPv6 support to rpc.nfsd (RFC)
Date: Mon, 11 May 2009 13:58:14 -0400
Message-ID: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:62313 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758639AbZEKR6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 13:58:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a first pass at adding IPv6 support to rpc.nfsd.

With the existing code on a relatively recent kernel with nfsdfs
mounted, rpc.nfsd will create IPv4 sockets and hand them off to the
kernel. The idea with this patchset is to have it do the same thing for
IPv6 sockets.

The kernel code for nfsd IPv6 support is not yet in place, so this code
isn't really very useful yet. I've tested this though against a patchset
from Chuck Lever's tree and seems to do the right thing there.

I've also done a bit of testing with this new code on existing kernels
and it seems to still work correctly.

It also optimizes the knfsd shutdown case a bit -- when setting the
threads to 0, the current code still opens sockets and hands them off to
the kernel, even though they'll never actually be used.

This patchset is just an RFC at the moment. The code is usable and
shouldn't break anything, but I'd like to see the kernel interfaces for
this in place before we commit this to the repo. It might be useful for
people working on IPv6 support for knfsd however.

Comments and suggestions appreciated.

Jeff Layton (3):
  nfs-utils: rearrange nfssvc.c
  nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
  nfs-utils: add IPv6 support to nfsd

 support/include/nfslib.h |    5 +-
 support/nfs/nfssvc.c     |   91 ++++++++++++++++++-----------
 utils/nfsd/nfsd.c        |  142 ++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 178 insertions(+), 60 deletions(-)

