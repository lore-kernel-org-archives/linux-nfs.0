From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: avoid possible deadlock bug when setting up
 delegation.
Date: Thu, 20 May 2010 08:57:16 -0400
Message-ID: <1274360236.2949.1.camel@heimdal.trondhjem.org>
References: <20100520054216.GA27457@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>
To: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36034 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326Ab0ETM5Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 08:57:24 -0400
In-Reply-To: <20100520054216.GA27457@vmware>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-05-20 at 13:42 +0800, Tao Guo wrote: 
> Unlock clp->cl_lock before taking inode->i_lock when setting up
> delegation to avoid possible deadlock bug.

What deadlock? inode->i_lock should always be the innermost lock, so it
should always be safe to take it while already holding the nfs_client
lock.

If somebody is taking the nfs_client lock while holding the inode lock,
then that would be the deadlock bug that needs to be fixed.

Trond

