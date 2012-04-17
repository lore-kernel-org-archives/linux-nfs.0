Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175Ab2DQNeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 09:34:03 -0400
Message-ID: <1334669598.5396.7.camel@localhost>
Subject: [PATCH 0/2] Prevent out of bounds reads when dealing with ACLs
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <trond.myklebust@netapp.com>,
        Andy Adamson <andros@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Tue, 17 Apr 2012 14:33:18 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit
bf118a342f10dafe44b14451a1392c3254629a1f
allows variable size bitmaps to be passed in the response to GETACL
calls.

The patch fails in a specific condition where
bitmap array size + acl length attribute size + ACLs > PAGE_SIZE
the code will read past the allocated buffer in nfs4_write_cached_acl()
and in _copy_from_pages().

A simple example is if the ACL size is just less than a PAGE_SIZE but
large enough so that ACL + Bitmap crosses a PAGE_SIZE, it will fail.
Another example is if the server sends a large bitmap array along with
smaller ACL data causing the bitmap array + ACL to go past the allocated
page, it will fail again.

To test the code, we configured pynfs to append 1000 extra elements to
the bitmap array which results in BITMAP+ACL size to be little over a
PAGE_SIZE. This leads to a General Protection Fault in
_copy_from_pages() on un-patched systems.


Sachin Prabhu (2):
  Avoid reading past buffer when calling GETACL
  Avoid beyond bounds copy while caching ACL

 fs/nfs/nfs4proc.c |   28 +++++++++++++++-------------
 fs/nfs/nfs4xdr.c  |   18 +++++++++++-------
 2 files changed, 26 insertions(+), 20 deletions(-)

-- 
1.7.7.6



