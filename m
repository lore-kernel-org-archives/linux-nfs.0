Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50520 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730395AbeG0QlO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 12:41:14 -0400
Subject: [PATCH v1 0/4] NFS/RDMA server patches for v4.19
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Jul 2018 11:18:48 -0400
Message-ID: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce et al. -

This short series includes clean-ups related to performance-related
work that you and I have discussed in the past. Let me give an
update on the progress of that work as context for these patches.

We had discussed moving the generation of RDMA Read requests from
->recvfrom up into the NFSD proc functions that handle WRITE and
SYMLINK operations. There were two reasons for this change:

1. To enable the upper layer to choose the pages that act as the
RDMA Read sink buffer, rather than always using anonymous pages
for this purpose

2. To reduce the average latency of ->recvfrom calls on RPC/RDMA,
which are serialized per transport connection

I was able to successfully prototype this change. The scope of this
prototype was limited to exploring how to move the RDMA Read code.
I have not yet tried to implement a per-FH page selection mechanism.

There was no measurable performance impact of this change. The good
news is that this confirms that the RDMA Read code can be moved
upstairs without negative performance consequences. The not-so-good
news:

- Serialization of ->recvfrom might not be the problem that I
predicted.

- I don't have a macro benchmark that mixes small NFS requests with
NFS requests with Read chunks in a way that can assess the
serialization issue.

- The most significant current bottleneck for NFS WRITE performance
is on the Linux client, which obscures performance improvements in
the server-side NFS WRITE path. The bottleneck is generic, not
related to the use of pNFS or the choice of transport type.

There were two architecture-related findings as well:

1. We were considering the need to double the size of the
svc_rqst::rq_pages array in order to reserve enough pages to con-
currently handle late RDMA Reads and building an RPC Reply. I found
a way to implement this prototype that did not require doubling the
size of this array. The transport reserves enough pages in that
array before ->recvfrom returns, and advances the respages pointer
accordingly. The upper layer can begin constructing the RPC Reply
immediately while the payload pages are filled later.

2. The prototype encountered an architectural issue with the
server's DRC. A checksum is computed on non-idempotent RPC Calls to
place them in the server's DRC hash table. That checksum includes
the first hundred or so bytes of the payload -- the data that would
be pulled over using RDMA Read. When RDMA Read is delayed, the
payload is not available for checksum computation.

To complete my prototype, I disabled the server's DRC. Going forward
with this work will require some thought about how to deal with non-
idempotent requests with Read chunks. Some possibilities:

- For RPC Calls with Read chunks, don't include the payload in the
checksum. This could be done by providing a per-transport checksum
callout that would manage the details.

- Support late RDMA Reads for session-based versions of NFS, but not
for earlier versions of NFS which utilize the legacy DRC.

- Adopt an entirely different DRC hashing mechanism.

---

Chuck Lever (4):
      svcrdma: Avoid releasing a page in svc_xprt_release()
      svcrdma: Clean up Read chunk path
      NFSD: Refactor the generic write vector fill helper
      NFSD: Handle full-length symlinks


 fs/nfsd/nfs3proc.c                      |    5 ++
 fs/nfsd/nfs4proc.c                      |   23 ++-------
 fs/nfsd/nfsproc.c                       |    5 ++
 include/linux/sunrpc/svc.h              |    4 +-
 net/sunrpc/svc.c                        |   78 ++++++++++++-------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    9 ++--
 net/sunrpc/xprtrdma/svc_rdma_rw.c       |   32 +++++--------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    4 +-
 8 files changed, 66 insertions(+), 94 deletions(-)

--
Chuck Lever
