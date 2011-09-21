Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:41204 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab1IUUGA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 16:06:00 -0400
Subject: Re: [PATCH] nfs: set vs_hidden on nfs4_callback_version4
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1316634942-5209-1-git-send-email-jlayton@redhat.com>
Date: Wed, 21 Sep 2011 16:05:45 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        skinsbursky@parallels.com
Message-Id: <EBF75C5F-DEA6-4703-A787-FCE68C6B72E3@oracle.com>
References: <1316634942-5209-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 21, 2011, at 3:55 PM, Jeff Layton wrote:

> This service should not be registered with or unregistered from rpcbind.

I've been watching the larger conversation.  One thing that registering does, even if you don't want to advertise your service, is tell you if there is already another service on that port.  Do we want to worry about possible port collisions for listeners like the callback service?

Do we want to ensure that any other service on that port is unregistered?  We would already discover a listener on our port when trying to create the socket, but an old registration may persist even after that old service has gone away.

This is something to think about when revisiting the semantics of .vs_hidden.

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/callback_xdr.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index c6c86a7..7c8b800 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -996,4 +996,5 @@ struct svc_version nfs4_callback_version4 = {
> 	.vs_proc = nfs4_callback_procedures1,
> 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
> 	.vs_dispatch = NULL,
> +	.vs_hidden = 1,
> };
> -- 
> 1.7.6.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




