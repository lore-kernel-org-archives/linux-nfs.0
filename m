From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] NFS: fix ERR_PTR with un mapped NFSv4 error
Date: Thu, 27 Nov 2008 15:12:08 -0500
Message-ID: <1227816728.10634.8.camel@heimdal.trondhjem.org>
References: <1227739740-5885-1-git-send-email-andros@netapp.com>
	 <492E490C.2030109@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23641 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbYK0UOb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Nov 2008 15:14:31 -0500
In-Reply-To: <492E490C.2030109@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-11-27 at 09:15 +0200, Benny Halevy wrote:
> Andy, I wonder if this actually needs to be done in
> lower-level functions (e.g. nfs_probe_fsinfo).
> I think that in general we should not let nfs errors
> out of the layer immediately invoking the xdr routines.

I agree. We're not processing the NFSv4-specific errors at that level,
so why pass them up in the first place?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
