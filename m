Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37116 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab2DIV4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 17:56:46 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1 fix page number calulation bug for filelayout decode buffer
Date: Mon,  9 Apr 2012 17:55:34 -0400
Message-Id: <1334008535-2875-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This fixes a bug when performing I/O over pNFS file layout with rsize
and/or wsize < PAGE_SIZE.

Andy Adamson (1):
  NFSv4.1 fix page number calulation bug for filelayout decode buffer

 fs/nfs/nfs4filelayoutdev.c |    2 +-
 fs/nfs/pnfs.c              |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
1.7.6.4

