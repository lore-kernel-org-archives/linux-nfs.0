Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF3NVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:25 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 00/12] add NFS over AF_VSOCK support
Date: Fri, 30 Jun 2017 14:21:08 +0100
Message-Id: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The AF_VSOCK address family allows virtual machines to communicate with the
hypervisor using a zero-configuration transport.  Both KVM and VMware
hypervisors support AF_VSOCK and it was introduced in Linux 3.9.

This patch series adds AF_VSOCK support to mount.nfs(8) and rpc.nfsd(8).

It requires the kernel NFS client patches that I am also posting to
linux-nfs@vger.kernel.org.  Please see the kernel patch series for an overview
of NFS over AF_VSOCK and quickstart instructions for testing.

This series extends exports(5) syntax to handle vsock:<CID> or vsock:*.  For
example, the guest with CID 3 can be given access using vsock:3.

The code is also available here:
https://github.com/stefanha/nfs-utils/tree/vsock-nfsd

Stefan Hajnoczi (12):
  mount: don't use IPPROTO_UDP for address resolution
  nfs-utils: add AF_VSOCK support to sockaddr.h
  mount: present AF_VSOCK addresses
  mount: accept AF_VSOCK in nfs_verify_family()
  getport: recognize "vsock" netid
  mount: AF_VSOCK address parsing
  exportfs: introduce host_freeaddrinfo()
  exportfs: add AF_VSOCK address parsing and printing
  exportfs: add AF_VSOCK support to set_addrlist()
  exportfs: add support for "vsock:" exports(5) syntax
  nfsd: add --vsock (-v) option to nfsd
  tests: add "vsock:" exports(5) test case

 tests/Makefile.am          |   3 +-
 support/include/exportfs.h |   6 ++
 support/include/sockaddr.h |  29 +++++++
 utils/nfsd/nfssvc.h        |   1 +
 support/export/client.c    |   8 +-
 support/export/hostname.c  | 183 +++++++++++++++++++++++++++++++++++++++++++--
 support/nfs/getport.c      |  16 +++-
 utils/exportfs/exportfs.c  |  42 +++++++++--
 utils/mount/network.c      |  10 ++-
 utils/mount/stropts.c      |  67 +++++++++++++++--
 utils/mountd/auth.c        |   2 +-
 utils/mountd/cache.c       |  10 +--
 utils/mountd/mountd.c      |   4 +-
 utils/mountd/rmtab.c       |   2 +-
 utils/nfsd/nfsd.c          |  18 ++++-
 utils/nfsd/nfssvc.c        |  62 +++++++++++++++
 tests/t0002-vsock-basic.sh |  53 +++++++++++++
 17 files changed, 474 insertions(+), 42 deletions(-)
 create mode 100755 tests/t0002-vsock-basic.sh

-- 
2.9.4

