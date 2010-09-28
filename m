From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: don't use FLUSH_SYNC on WB_SYNC_NONE COMMIT calls
 (try #2)
Date: Tue, 28 Sep 2010 09:30:11 -0400
Message-ID: <1285680611.9185.5.camel@heimdal.trondhjem.org>
References: <1285679641-19763-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: fengguang.wu@gmail.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10607 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab0I1NaV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 09:30:21 -0400
In-Reply-To: <1285679641-19763-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-09-28 at 09:14 -0400, Jeff Layton wrote:
> WB_SYNC_NONE is supposed to mean "don't wait on anything". That should
> also include not waiting for COMMIT calls to complete.
> 
> WB_SYNC_NONE is also implied when wbc->nonblocking and
> wbc->for_background are set, so we can replace those checks in
> nfs_commit_unstable_pages with a check for WB_SYNC_NONE.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks. Applied to nfs-for-next...

Cheers
  Trond
