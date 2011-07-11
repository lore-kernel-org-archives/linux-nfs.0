Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36508 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758403Ab1GKSI3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2011 14:08:29 -0400
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p6BI8Txm002417
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2011 11:08:29 -0700 (PDT)
Subject: Re: [PATCH 1/1] NFSv4.1: handle decoding of three attribute bitmaps
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 11 Jul 2011 14:08:28 -0400
In-Reply-To: <1310406847-31297-1-git-send-email-andros@netapp.com>
References: <1310406847-31297-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1310407708.12660.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-07-11 at 13:54 -0400, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Attribute IDs assigned in RFC 5661 now require three bitmaps.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Cc:stable@kernel.org [2.6.39]

Is this really so urgent?

[trondmy@lade linux-2.6]$ git grep FATTR4_WORD2 fs/nfs include/linux
include/linux/nfs4.h:#define FATTR4_WORD2_SUPPATTR_EXCLCREAT (1UL << 11)
include/linux/nfs4.h:#define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)

IOW: we don't appear to be using any of those bits, and so the current
default behaviour of just ignoring any bitmap values that we don't
recognise would seem to be sufficient.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

