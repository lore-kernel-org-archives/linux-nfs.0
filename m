Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932468AbdA0Nda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Jan 2017 08:33:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        lustre-devel@lists.lustre.org, v9fs-developer@lists.sourceforge.net
Subject: [PATCH v4 0/2] iov_iter: allow iov_iter_get_pages_alloc to allocate more pages per call
Date: Fri, 27 Jan 2017 08:24:49 -0500
Message-Id: <20170127132451.6601-1-jlayton@redhat.com>
In-Reply-To: <1485434106.6547.1.camel@poochiereds.net>
References: <1485434106.6547.1.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v1: Initial iteration (too many iov_iter details exposed to callers)
v2: just change iov_iter_get_pages_alloc to add more pages to the array
    if the previous vector and the current one are page aligned
v3: Move maxsize handling into iov_iter_pvec_size. Add patch to make
    ceph use iov_iter_get_pages_alloc instead of doing its own thing.
v4: Fix length handling when neither start nor end of iovec is page
    aligned. Rework error handling when there is a change to iovec
    after calculating the array length. Eliminate a BUG_ON.

Currently iov_iter_get_pages_alloc doesn't actually iterate past the
first element in the vector array. If you have a long array of small
iovecs that are well aligned and you want to stitch them together into a
single I/O, you have to try to do it yourself with multiple calls to
iov_iter_get_pages.

Ceph attempts to do this, but it doesn't handle ITER_BVEC correctly,
which is necessary to handle splice writes into a file open with
O_DIRECT. That usually leads to a softlockup with the current code.

While I can't locate the report at the moment, ISTR that we've also had
people complain in the past that the NFS client doesn't handle small
iovecs well with O_DIRECT. Each iovec gets its own RPC, even when they
are page-aligned. The first patch in the series fixes that as well.

This may also silimarly help lustre and 9p in that situation as well,
but I don't have a great way to test that so I can't verify it.

Jeff Layton (2):
  iov_iter: allow iov_iter_get_pages_alloc to allocate more pages per
    call
  ceph: switch DIO code to use iov_iter_get_pages_alloc

 fs/ceph/file.c |  75 +-----------------------
 lib/iov_iter.c | 180 +++++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 154 insertions(+), 101 deletions(-)

-- 
2.9.3

