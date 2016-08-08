Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:64575 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbcHHO0I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2016 10:26:08 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 0/3] Client reconnection fixes
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
References: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
Message-ID: <963f74cb-9e46-72c8-5168-840021dc0453@Netapp.com>
Date: Mon, 8 Aug 2016 10:26:00 -0400
MIME-Version: 1.0
In-Reply-To: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Do these patches depend on another patch set?  I tried applying the first patch, but my git tree is missing sha1 information for net/sunrpc/xprtsock.c.

Thanks,
Anna

On 08/05/2016 07:37 PM, Trond Myklebust wrote:
> v1: Cap the backoff timer to the max RPC message timeout
> v2: Add a cap at 1/2 NFSv4 lease period to ensure we don't miss lease renewal
>
> Trond Myklebust (3):
>   SUNRPC: Limit the reconnect backoff timer to the max RPC message
>     timeout
>   NFSv4: Cleanup the setting of the nfs4 lease period
>   NFSv4: Cap the transport reconnection timer at 1/2 lease period
>
>  fs/nfs/nfs4_fs.h            |  4 ++++
>  fs/nfs/nfs4proc.c           |  9 +++------
>  fs/nfs/nfs4renewd.c         | 20 ++++++++++++++++++++
>  fs/nfs/nfs4state.c          |  9 +++------
>  include/linux/sunrpc/clnt.h |  2 ++
>  include/linux/sunrpc/xprt.h |  3 ++-
>  net/sunrpc/clnt.c           | 24 ++++++++++++++++++++++++
>  net/sunrpc/xprtsock.c       | 18 ++++++++++++------
>  8 files changed, 70 insertions(+), 19 deletions(-)
>

