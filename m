Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35270 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148AbbGJKp7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 06:45:59 -0400
Received: by pactm7 with SMTP id tm7so166726805pac.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 03:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150709204208.26247.52073.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
	<20150709204208.26247.52073.stgit@manet.1015granger.net>
Date: Fri, 10 Jul 2015 16:15:58 +0530
Message-ID: <CANjDDBiMDM5VP5ev3LFfapX-5amqukH=dJdaEZVcZc9SSP2CCg@mail.gmail.com>
Subject: Re: [PATCH v1 03/12] xprtrdma: Increase default credit limit
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Increasing the default slot table entries will increase the MR
requirements per mount.

Currently, with 32 as default Client ends up allocating 2178 frmrs
(ref: kernel 4.1-rc4) for a single mount. With 128 frmr requirement
for startup would be 8448.

8K+ MRs per mount just for start-up, I am a little doubtful about this
change. We can always release-note that "for better performance
increase the slot table entries by echo 128 >
/proc/sys/sunrpc/rdma_slot_table_entries"

-Regards
Devesh

On Fri, Jul 10, 2015 at 2:12 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> In preparation for similar increases on NFS/RDMA servers, bump the
> advertised credit limit for RPC/RDMA to 128. This allocates some
> extra resources, but the client will continue to allow only the
> number of RPCs in flight that the server requests via its advertised
> credit limit.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/xprtrdma.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
> index b176130..b7b279b 100644
> --- a/include/linux/sunrpc/xprtrdma.h
> +++ b/include/linux/sunrpc/xprtrdma.h
> @@ -49,7 +49,7 @@
>   * a single chunk type per message is supported currently.
>   */
>  #define RPCRDMA_MIN_SLOT_TABLE (2U)
> -#define RPCRDMA_DEF_SLOT_TABLE (32U)
> +#define RPCRDMA_DEF_SLOT_TABLE (128U)
>  #define RPCRDMA_MAX_SLOT_TABLE (256U)
>
>  #define RPCRDMA_DEF_INLINE  (1024)     /* default inline max */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
