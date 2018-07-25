Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39044 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728492AbeGYONX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2018 10:13:23 -0400
Date: Wed, 25 Jul 2018 08:59:49 -0400
From: Neil Horman <nhorman@tuxdriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: davem@davemloft.net, ericvh@gmail.com, rminnich@sandia.gov,
        lucho@ionkov.net, ralf@linux-mips.org, jreuter@yaina.de,
        pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        alex.aring@gmail.com, stefan@datenfreihafen.org,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        johannes@sipsolutions.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, vyasevich@gmail.com,
        marcelo.leitner@gmail.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, netdev@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, linux-hams@vger.kernel.org,
        ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
Subject: Re: [PATCH PATCH net-next 08/18] sctp: whitespace fixes
Message-ID: <20180725125949.GB3622@hmswarspite.think-freely.org>
References: <20180724192918.31165-1-sthemmin@microsoft.com>
 <20180724192918.31165-9-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180724192918.31165-9-sthemmin@microsoft.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2018 at 12:29:08PM -0700, Stephen Hemminger wrote:
> Remove blank line at EOF and trailing whitespace.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> ---
>  net/sctp/Kconfig         | 4 ++--
>  net/sctp/sm_sideeffect.c | 1 -
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> index c740b189d4ba..950ecf6e7439 100644
> --- a/net/sctp/Kconfig
> +++ b/net/sctp/Kconfig
> @@ -41,8 +41,8 @@ config SCTP_DBG_OBJCNT
>  	bool "SCTP: Debug object counts"
>  	depends on PROC_FS
>  	help
> -	  If you say Y, this will enable debugging support for counting the 
> -	  type of objects that are currently allocated.  This is useful for 
> +	  If you say Y, this will enable debugging support for counting the
> +	  type of objects that are currently allocated.  This is useful for
>  	  identifying memory leaks. This debug information can be viewed by
>  	  'cat /proc/net/sctp/sctp_dbg_objcnt'
>  
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 298112ca8c06..85d393090238 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -1827,4 +1827,3 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
>  	error = -ENOMEM;
>  	goto out;
>  }
> -
> -- 
> 2.18.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

