Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35483 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab2ADT4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:56:34 -0500
Received: by vcbfk14 with SMTP id fk14so13490667vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:56:34 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Bug fixes and NFS junction support
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:56:30 -0500
Message-ID: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Four minor bug fix patches, for what they're worth, then...

The fifth patch adds support in mountd for loading a plug-in to
resolve NFS junctions.  The plug-in will be provided by fedfs-utils.
Source code will be posted very soon for review.

We'd like to see this in Fedora 17, if convenient.  Meantime, let's
review what I've got.

---

Chuck Lever (5):
      mountd: Support junction management plug-ins
      mountd: remove newline from xlog() format specifier strings
      mountd: Plug v4root memory leak
      configure.ac: Don't check for AI_ADDRCONFIG
      configure.ac: Clean up help string for --with-statdpath


 aclocal/ipv6.m4          |   11 --
 configure.ac             |   10 +-
 utils/mountd/Makefile.am |    2 
 utils/mountd/cache.c     |  225 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/mountd/fsloc.c     |   10 +-
 utils/mountd/v4root.c    |    2 
 6 files changed, 237 insertions(+), 23 deletions(-)

-- 
Chuck Lever
