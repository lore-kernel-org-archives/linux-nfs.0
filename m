Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:55928 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724Ab2HUGUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 02:20:34 -0400
Message-ID: <503328AF.5030506@msgid.tls.msk.ru>
Date: Tue, 21 Aug 2012 10:20:31 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping
References: <20120820223746.GL5779@fieldses.org>
In-Reply-To: <20120820223746.GL5779@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21.08.2012 02:37, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The rpc server tries to ensure that there will be room to send a reply
> before it receives a request.
> 
> It does this by tracking, in xpt_reserved, an upper bound on the total
> size of the replies that is has already committed to for the socket.
> 
> Currently it is adding in the estimate for a new reply *before* it
> checks whether there is space available.  If it finds that there is not
> space, it then subtracts the estimate back out.
> 
> This may lead the subsequent svc_xprt_enqueue to decide that there is
> space after all.
> 
> The results is a svc_recv() that will repeatedly return -EAGAIN, causing
> server threads to loop without doing any actual work.
> 
> Cc: stable@vger.kernel.org

This is applicable to all 3.0+ stable kernels.  The commit which
made this bug apparent is included into 3.0-rc5 (changing memory
buffer sizes for tcp/udp/stcp).  Before that commit, this bug is
not triggered, at least here.  So 3.0, 3.2, 3.4 and 3.5 (for which
stable series are maintained at the moment) definitely should
include it.

Should it be applied to 2.6.32 &Co too?

/mjt

> Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
