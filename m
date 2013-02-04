Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1643 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754491Ab3BDOWx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 09:22:53 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: RE: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
Date: Mon, 4 Feb 2013 14:22:47 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91835B2E9@SACEXCMBX04-PRD.hq.netapp.com>
References: <1359983408-28337-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983408-28337-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Jeff Layton
> Sent: Monday, February 04, 2013 8:10 AM
> To: bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org; chuck.lever@oracle.com
> Subject: [PATCH] sunrpc: copy scope ID in __rpc_copy_addr6
> 
> When copying an address, we should also copy the scopeid in the event that
> this is a link-local address and the scope matters.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/sunrpc/clnt.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h index
> 47354a2..6a7c261 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -242,6 +242,7 @@ static inline bool __rpc_copy_addr6(struct sockaddr
> *dst,
> 
>  	dsin6->sin6_family = ssin6->sin6_family;
>  	dsin6->sin6_addr = ssin6->sin6_addr;
> +	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
>  	return true;
>  }
>  #else	/* !(IS_ENABLED(CONFIG_IPV6) */
> --

Oh... Also note that you probably want to apply the above scopeid to the NFSv4 callback address that is supplied by the client in the setclientid call.

Trond
