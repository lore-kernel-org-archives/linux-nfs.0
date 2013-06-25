Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15583 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab3FYXDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jun 2013 19:03:13 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/3] NFSv4.1 Fix gdia_maxcount calculation to fit in ca_maxresponsesize
Date: Tue, 25 Jun 2013 19:02:52 -0400
Message-Id: <1372201375-6686-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

>From Trond:
> The problem is that pdev->pglen is used both as the total buffer length,
> as a function argument and as the reply message length (through the call
> to xdr_init_decode_pages). We really should split out those 3 different
> roles...

AFAICS there are two roles: the reply or total message length used for
xdr_init_decode_pages (where it is also a function argument) and the 
gdia_maxcount. 

Put the block and object layout change in separate patches for ease of
backporting.

-->Andy

Andy Adamson (3):
  NFSv4.1 Fix gdia_maxcount calculation to fit in ca_maxresponsesize
  NFSv4.1 use pnfs_device maxcount for the blocklayout gdia_maxcount
  NFSv4.1 use pnfs_device maxcount for the objectlayout gdia_maxcount

 fs/nfs/blocklayout/blocklayout.c | 1 +
 fs/nfs/internal.h                | 1 +
 fs/nfs/nfs4filelayoutdev.c       | 1 +
 fs/nfs/nfs4xdr.c                 | 8 +++++++-
 fs/nfs/objlayout/objlayout.c     | 1 +
 fs/nfs/pnfs.h                    | 3 ++-
 6 files changed, 13 insertions(+), 2 deletions(-)

-- 
1.7.11.7

