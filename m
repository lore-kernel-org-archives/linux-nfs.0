Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28519 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083Ab2DTSsF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:05 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 00/25] directio rewrite
Date: Fri, 20 Apr 2012 14:47:32 -0400
Message-Id: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

version 2 of these patches had some patch fragments that were left
unsquashed.  This version merely squashes those in.



These patches rewrite the directio code to use the same coalesce
and RPC sendoff code as cached io.  This allows directio to make
use of the preexisting pnfs code.

There are some limitations at the moment that need to be fixed, but
given the amount of change this patchset introduces I'm
trying to put out as small a base set of patches as possible.

The primary TODOs are:
- Coalescing of bsize<PAGESIZE, while technically correct, is suboptimal.
  To fix this I'll need to adjust the *_multi functions to handle
  more than a single req

- Unaligned io is not sent to pnfs, as there is no existing code to deal
  with a layout boundary (think stripe edge) occurring in the middle
  of a nfs_page.

Fred

