From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] NFS: Don't generate a GETATTR when opening an
 O_DIRECT file
Date: Thu, 11 Feb 2010 14:45:56 -0500
Message-ID: <1265917556.478.40.camel@localhost>
References: <20100211185757.2666.90001.stgit@localhost.localdomain>
	 <20100211190918.2666.82008.stgit@localhost.localdomain>
	 <1265915652.478.22.camel@localhost>  <4B745872.7020807@oracle.com>
	 <1265916841.478.31.camel@localhost>  <4B745D6B.8060601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39278 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405Ab0BKTqB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Feb 2010 14:46:01 -0500
In-Reply-To: <4B745D6B.8060601@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-02-11 at 14:41 -0500, Chuck Lever wrote: 
> Does it make sense to drop this patch?

Yes, I think the gains would be minimal (although I'd be happy to be
proven wrong).

Cheers
  Trond

