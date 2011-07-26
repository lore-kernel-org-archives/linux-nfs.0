Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62626 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab1GZOuL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 10:50:11 -0400
Received: by yxi11 with SMTP id 11so290202yxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 07:50:11 -0700 (PDT)
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6 when libtirpc is enabled
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1311683346-16881-1-git-send-email-steved@redhat.com>
Date: Tue, 26 Jul 2011 16:50:06 +0200
Cc: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com>
References: <1311683346-16881-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 26, 2011, at 2:29 PM, Steve Dickson wrote:

> From: Ian Kent <raven@themaw.net>
> 
> The IPv6 client functions clntudp6_bufcreate(), clntudp6_create and
> clnttcp6_create and the server functions svcudp6_bufcreate(),
> svctcp6_create() and svcudp6_create() are not included in the library
> whe libtirpc is built.

Are these part of the libtirpc standard API?  I'm not sure why we would need them if, say, Solaris does not support these.

> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/rpc_soc.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> index c678429..584ac71 100644
> --- a/src/rpc_soc.c
> +++ b/src/rpc_soc.c
> @@ -236,7 +236,7 @@ clnttcp_create(raddr, prog, vers, sockp, sendsz, recvsz)
> 
> /* IPv6 version of clnt*_*create */
> 
> -#ifdef INET6_NOT_USED
> +#ifdef INET6
> 
> CLIENT *
> clntudp6_bufcreate(raddr, prog, vers, wait, sockp, sendsz, recvsz)
> @@ -392,7 +392,7 @@ svcraw_create()
> 
> 
> /* IPV6 version */
> -#ifdef INET6_NOT_USED
> +#ifdef INET6
> SVCXPRT *
> svcudp6_bufcreate(fd, sendsz, recvsz)
> 	int fd;
> -- 
> 1.7.6
> 
> 
> ------------------------------------------------------------------------------
> Magic Quadrant for Content-Aware Data Loss Prevention
> Research study explores the data loss prevention market. Includes in-depth
> analysis on the changes within the DLP market, and the criteria used to
> evaluate the strengths and weaknesses of these DLP solutions.
> http://www.accelacomm.com/jaw/sfnl/114/51385063/
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

