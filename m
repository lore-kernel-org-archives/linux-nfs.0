Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10921 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218Ab1KKCHv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 21:07:51 -0500
Message-ID: <1320977270.24288.21.camel@lade.trondhjem.org>
Subject: Re: [PATCH] SQUASHME: pnfsd: Don't call fs_layout_return on a
 none-file
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <benny@tonian.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Thu, 10 Nov 2011 21:07:50 -0500
In-Reply-To: <4EBC5538.7010002@panasas.com>
References: <4EBC5538.7010002@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-10 at 14:50 -0800, Boaz Harrosh wrote: 
> So why does the Linux wonderful forgetfull client returnes it's ROC layouts on
> inode evict() (I hit this on umount at client). Actually this is on me, because
> it is a bug in Generic client code, but can only manifest with pnf-obj after an
> IO error.

Client patches are still welcome...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

