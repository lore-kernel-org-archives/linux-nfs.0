Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbaGKTYS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 15:24:18 -0400
Date: Fri, 11 Jul 2014 15:24:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Srikrishan Malik <srimalik@in.ibm.com>
Cc: linux-nfs@vger.kernel.org, nfs-ganesha-devel@lists.sourceforge.net
Subject: Re: [PATCH] Use original reserved port setting for reconnect.
Message-ID: <20140711192417.GH9775@fieldses.org>
References: <1405007526-2234-1-git-send-email-srimalik@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405007526-2234-1-git-send-email-srimalik@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Thu, Jul 10, 2014 at 09:22:06PM +0530, Srikrishan Malik wrote:
> Signed-off-by: Srikrishan Malik <srimalik@in.ibm.com>
> ---
> Reconnect ignores the "--secure" arg after connection reset.                  
> If the export is secure then OPs after reconnect fail with NFS4ERR_ACCESS.
>  nfs4.0/lib/rpc/rpc.py |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
> index 8b39df4..5ef2e3e 100644
> --- a/nfs4.0/lib/rpc/rpc.py
> +++ b/nfs4.0/lib/rpc/rpc.py
> @@ -305,7 +305,8 @@ class RPCClient(object):
>          self.lock.acquire()
>          self._socket[t].close()
>          out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
> -        # out.bind
> +        if self.uselowport:
> +            self.bindsocket(out)
>          out.connect((self.remotehost, self.remoteport))
>          out.settimeout(self.timeout)
>          self.lock.release()
> -- 
> 1.7.1
> 
