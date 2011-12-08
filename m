Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:26078 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420Ab1LHVkd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 16:40:33 -0500
Subject: Re: [RFC][PATCH] libtirpc,rpcbind: move socket from /var/run to /run
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1323371940-9140-1-git-send-email-teg@jklm.no>
Date: Thu, 8 Dec 2011 16:40:21 -0500
Cc: linux-nfs@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>
Message-Id: <76A6354E-54A6-4088-9425-B6BB2CE3C92B@oracle.com>
References: <1323371940-9140-1-git-send-email-teg@jklm.no>
To: Tom Gundersen <teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 8, 2011, at 2:19 PM, Tom Gundersen wrote:

> /run is guaranteed to be available and writeable at any time, whereas
> /var might be on a separate partition and hence not available during
> early boot. By moving the socket from /var to /run we are able to use
> rpcbind earlier, which would in particular make a difference in case
> /var is on an nfs mount, something I am currently seeing bug reports
> about.

I don't understand this part.  /var should be mounted with "nolock" so there should not be a need to have rpcbind running.  Can you explain what this is about?

> This change should not make a difference to software that currently
> works as intended, as /var/run should be a symlink or bindmounted
> to /run, so anyone relying on the socket being in /var/run will
> still find it there.

Even the kernel?

> The /run directory is supported by all the major distributions
> (at least Debian, Fedora, Suse, Ubuntu and Arch from what I can gather).
> See http://wiki.debian.org/ReleaseGoals/RunDirectory and
> http://thread.gmane.org/gmane.linux.redhat.fedora.devel/146976 for some
> more details.
> 
> Cc: Kay Sievers <kay.sievers@vrfy.org>
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> ---
> tirpc/rpc/rpcb_prot.h |    2 +-
> tirpc/rpc/rpcb_prot.x |    2 +-
> 2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tirpc/rpc/rpcb_prot.h b/tirpc/rpc/rpcb_prot.h
> index 7ae48b8..63b4a2c 100644
> --- a/tirpc/rpc/rpcb_prot.h
> +++ b/tirpc/rpc/rpcb_prot.h
> @@ -476,7 +476,7 @@ extern bool_t xdr_netbuf(XDR *, struct netbuf *);
> #define RPCBVERS_3 RPCBVERS
> #define RPCBVERS_4 RPCBVERS4
> 
> -#define _PATH_RPCBINDSOCK "/var/run/rpcbind.sock"
> +#define _PATH_RPCBINDSOCK "/run/rpcbind.sock"
> 
> #else /* ndef _KERNEL */
> #ifdef __cplusplus
> diff --git a/tirpc/rpc/rpcb_prot.x b/tirpc/rpc/rpcb_prot.x
> index b21ac3d..ebe1e60 100644
> --- a/tirpc/rpc/rpcb_prot.x
> +++ b/tirpc/rpc/rpcb_prot.x
> @@ -410,7 +410,7 @@ program RPCBPROG {
> %#define	RPCBVERS_3		RPCBVERS
> %#define	RPCBVERS_4		RPCBVERS4
> %
> -%#define	_PATH_RPCBINDSOCK	"/var/run/rpcbind.sock"
> +%#define	_PATH_RPCBINDSOCK	"/run/rpcbind.sock"
> %
> %#else		/* ndef _KERNEL */
> %#ifdef __cplusplus
> -- 
> 1.7.8
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




