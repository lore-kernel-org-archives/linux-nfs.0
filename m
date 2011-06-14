Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab1FNSpz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 14:45:55 -0400
Subject: Re: [PATCH 1/2] nfs_xdr: Move nfs4_string definition out of #ifdef
 CONFIG_NFS_V4
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Date: Tue, 14 Jun 2011 14:45:52 -0400
In-Reply-To: <4DF67918.6010202@panasas.com>
References: <4DF678C5.1080001@panasas.com> <4DF67918.6010202@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308077153.2499.0.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-06-13 at 16:54 -0400, Boaz Harrosh wrote: 
> exofs file system wants to use pnfs_osd_xdr.h file instead of
> redefining pnfs-objects types in it's private "pnfs.h" headr.
> 
> Before we do the switch we must make sure pnfs_osd_xdr.h is
> compilable also under NFS versions smaller than 4.1. Since now
> it is needed regardless of version, by the exofs code.
> 
> Only miss-out is nfs4_string move it to global scope.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

