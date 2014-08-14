Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:52593 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbaHNVjj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 17:39:39 -0400
Received: by mail-ig0-f178.google.com with SMTP id uq10so214722igb.5
        for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 14:39:38 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 0/2] RFC: Fix nfs_generic_pgio page vector issues
Date: Thu, 14 Aug 2014 17:39:31 -0400
Message-Id: <1408052373-4306-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes a few issues with the creation of nfs_pageio_descriptor
page vectors, which are passed to nfs_pgio_header structures.

These were first found by Toralf Förster <toralf.foerster@gmx.de> by running
trinity, but I've since received a report of a real world usecase that
hit a related issue: kvm with cache=none.

There are two problems that are closely related and seem to only be triggered
by direct i/o writev()/readv() calls.

The fixes are:
  - do not coalesce pages unless they are contiguous in file position *and*
    within / betwen pages.

  - do not allow duplicated pages in the pagevector


I'm still testing these, but I thought I'd share what I have with the list.

 -dros

Weston Andros Adamson (2):
  nfs: disallow duplicate pages in pgio page vectors
  nfs: can_coalesce_requests must enforce contiguity

 fs/nfs/pagelist.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

-- 
1.8.5.2 (Apple Git-48)

