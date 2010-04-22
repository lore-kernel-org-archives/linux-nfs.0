From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 5/5] NFS: Fix an unstable write data integrity race
Date: Thu, 22 Apr 2010 16:55:35 -0400
Message-ID: <1271969735.5693.1.camel@localhost.localdomain>
References: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1271969421-7443-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1271969421-7443-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1271969421-7443-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1271969421-7443-6-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44213 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758750Ab0DVUzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:55:40 -0400
Received: from mail-mx4.uio.no ([129.240.10.45])
	by mail-out2.uio.no with esmtp (Exim 4.69)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1O53Qx-0003bb-7r
	for linux-nfs@vger.kernel.org; Thu, 22 Apr 2010 22:55:39 +0200
Received: from c-68-40-206-115.hsd1.mi.comcast.net ([68.40.206.115] helo=[192.168.1.6])
	by mail-mx4.uio.no with esmtpsa (SSLv3:CAMELLIA256-SHA:256)
	user trondmy (Exim 4.69)
	(envelope-from <trond.myklebust@fys.uio.no>)
	id 1O53Qw-0001at-HQ
	for linux-nfs@vger.kernel.org; Thu, 22 Apr 2010 22:55:39 +0200
In-Reply-To: <1271969421-7443-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-04-22 at 16:50 -0400, Trond Myklebust wrote: 
> Commit 2c61be0a9478258f77b66208a0c4b1f5f8161c3c (NFS: Ensure that the WRITE
> and COMMIT RPC calls are always uninterruptible) exposed a race on file
> close. In order to ensure correct close-to-open behaviour, we want to wait
> for all outstanding background commit operations to complete.
> 
> This patch adds an inode flag that indicates if a commit operation is under
> way, and provides a mechanism to allow ->write_inode() to wait for its
> completion if this is a data integrity flush.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---

BTW: There is a bugzilla report associated to this problem:
   https://bugzilla.kernel.org/show_bug.cgi?id=15819

Cheers
  Trond

