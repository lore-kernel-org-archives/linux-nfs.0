From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Fix xdr decoding error of NFSv4 SETATTR response
Date: Tue, 28 Apr 2009 08:32:56 -0400
Message-ID: <1240921976.7376.11.camel@heimdal.trondhjem.org>
References: <1240921174-25443-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbZD1Mdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 08:33:31 -0400
In-Reply-To: <1240921174-25443-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-04-28 at 15:19 +0300, Benny Halevy wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> A non-OK response to setattr has a bitmap associated with it
> that was not being parsed.  Note it is still being ignored.
> 
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> 
> Trond, this patch fixes an existing bug in the nfsv4 code base.
> Since nobody complained about it so far it is not urgent for
> for 2.6.30, but it would be nice to get it upstream if you
> send more fixes for 2.6.30 anyway.

No, this really needs to be part of a larger patch to actually make use
of that bitmap. Otherwise it isn't really useful.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
