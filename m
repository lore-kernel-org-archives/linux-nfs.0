Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34178 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757367Ab2DTSgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:36:46 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 00/28]
Date: Fri, 20 Apr 2012 14:35:42 -0400
Message-Id: <1334946970-27470-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches rewrite the directio code to use the same coalesce
and RPC sendoff code as cached io.  This allows directio to make
use of the preexisting pnfs code.

There are some limitations at the moment that need to be fixed, but
given the amount of change this patchset introduces I'm
trying to put out as small a base set of patches as possible.

This set of patches responds to comments from the previous version,
as well as including a number of bugfixes.


The primary TODOs are:
- Coalescing of bsize<PAGESIZE, while technically correct, is suboptimal.
  To fix this I'll need to adjust the *_multi functions to handle
  more than a single req

- Unaligned io is not sent to pnfs, as there is no existing code to deal
  with a layout boundary (think stripe edge) occurring in the middle
  of a nfs_page.

Fred

