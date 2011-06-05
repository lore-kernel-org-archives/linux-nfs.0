Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63612 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756366Ab1FEW45 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2011 18:56:57 -0400
Received: by iyb14 with SMTP id 14so2701849iyb.19
        for <linux-nfs@vger.kernel.org>; Sun, 05 Jun 2011 15:56:57 -0700 (PDT)
References: <1307288638-32215-1-git-send-email-steved@redhat.com>
In-Reply-To: <1307288638-32215-1-git-send-email-steved@redhat.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <44DFB4C2-AD75-412F-B211-D6DB1B9D2ACE@gmail.com>
Cc: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Chuck Lever <chucklever@gmail.com>
Subject: Re: [Libtirpc-devel] [PATCH] Do not skip records with nonblocking connections
Date: Sun, 5 Jun 2011 18:57:01 -0400
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Sent from my iPad

On Jun 5, 2011, at 11:43 AM, Steve Dickson <steved@redhat.com> wrote:

> With non-blocking connections, do not skip records when receiving
> the streams since entire value messages can be ignored which
> in cause the entire stream to become out of sync.
> 
> For example, two mounts simultaneously send two unmaps
> commands. The first one is read, then the second thrown
> away due to skipping the record. Skipping this record
> will cause XDR error later in processing of the stream.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/svc_vc.c |    5 +++++
> 1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/src/svc_vc.c b/src/svc_vc.c
> index aaaf2d7..15dac18 100644
> --- a/src/svc_vc.c
> +++ b/src/svc_vc.c
> @@ -610,6 +610,11 @@ svc_vc_recv(xprt, msg)
>    }
> 
>    xdrs->x_op = XDR_DECODE;
> +    /*
> +     * No need skip records with nonblocking connections
> +     */
> +    if (cd->nonblock == FALSE)
> +        (void)xdrrec_skiprecord(xdrs);
>    (void)xdrrec_skiprecord(xdrs);

Do you want to delete the unconditional invocation of xdrrec_skiprecord() here?

>    if (xdr_callmsg(xdrs, msg)) {
>        cd->x_id = msg->rm_xid;
> -- 
> 1.7.4.4
> 
> 
> ------------------------------------------------------------------------------
> Simplify data backup and recovery for your virtual environment with vRanger.
> Installation's a snap, and flexible recovery options mean your data is safe,
> secure and there when you need it. Discover what all the cheering's about.
> Get your free trial download today. 
> http://p.sf.net/sfu/quest-dev2dev2 
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
