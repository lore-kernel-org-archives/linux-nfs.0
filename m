Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:49061 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755909AbbKERUm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 12:20:42 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Anna Schumaker'" <Anna.Schumaker@netapp.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: <linux-nfs@vger.kernel.org>, "Chuck Lever" <chuck.lever@oracle.com>
References: <560AFB37.4080609@Netapp.com>
In-Reply-To: <560AFB37.4080609@Netapp.com>
Subject: RE: [GIT PULL] Please pull an NFSoRDMA client bugfix
Date: Thu, 5 Nov 2015 11:20:47 -0600
Message-ID: <01c101d117ee$4f87f320$ee97d960$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anna and Trond,

Does it make sense for this to be pushed into stable as well?  It can cause a touch-after-free crash on iWARP transports. 

Steve.

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Anna Schumaker
> Sent: Tuesday, September 29, 2015 3:57 PM
> To: Trond Myklebust
> Cc: linux-nfs@vger.kernel.org; Steve Wise
> Subject: [GIT PULL] Please pull an NFSoRDMA client bugfix
> 
> Hi Trond,
> 
> The following changes since commit d0f36c46deea97bd16b9277be2f1acac74d76037:
> 
>   xprtrdma: take HCA driver refcount at client (2015-08-05 16:22:56 -0400)
> 
> are available in the git repository at:
> 
>   git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-4.3-2
> 
> for you to fetch changes up to 72c021738252dde5849d575a650239d6404930ee:
> 
>   xprtrdma: disconnect and flush cqs before freeing buffers (2015-09-28 10:42:35 -0400)
> 
> Thanks,
> Anna
> 
> ----------------------------------------------------------------
> Steve Wise (1):
>       xprtrdma: disconnect and flush cqs before freeing buffers
> 
>  net/sunrpc/xprtrdma/transport.c | 2 +-
>  net/sunrpc/xprtrdma/verbs.c     | 9 ++++++---
>  2 files changed, 7 insertions(+), 4 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

