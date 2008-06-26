From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/4] NFS: Set security flavor default for NFSv2/3
	mounts like other defaults
Date: Thu, 26 Jun 2008 15:48:04 -0400
Message-ID: <1214509684.7503.2.camel@localhost>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
	 <20080624203345.3366.31456.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16047 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbYFZTso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jun 2008 15:48:44 -0400
In-Reply-To: <20080624203345.3366.31456.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-24 at 16:33 -0400, Chuck Lever wrote:
> Set the default security flavor when we set the other mount option default
> values.  After this change, only the legacy user-space mount path needs to
> set the NFS_MOUNT_SECFLAVOUR flag.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/super.c |   22 +++++-----------------
>  1 files changed, 5 insertions(+), 17 deletions(-)
> 

Does not apply to the devel tree...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
