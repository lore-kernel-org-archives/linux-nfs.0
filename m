Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24228 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032811AbbKEOGv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 09:06:51 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [patch 1/2] xprtrdma: clean up some curly braces
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151105083708.GA19405@mwanda>
Date: Thu, 5 Nov 2015 09:06:36 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Doug Ledford <dledford@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-Id: <F97535F6-6BC8-430E-B346-9BAA41693DE8@oracle.com>
References: <20151105083708.GA19405@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 5, 2015, at 3:37 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> It doesn't matter either way, but the curly braces were clearly intended
> here.  It causes a Smatch warning.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index eadd1655..2cc1014 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -852,10 +852,11 @@ retry:
> 
> 		if (extras) {
> 			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
> -			if (rc)
> +			if (rc) {
> 				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
> 					__func__, rc);
> 				rc = 0;
> +			}
> 		}
> 	}
> 

—
Chuck Lever



