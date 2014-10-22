Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970AbaJVPdx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 11:33:53 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s9MFXrTA032575
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2014 11:33:53 -0400
Message-ID: <5447CE60.2020202@RedHat.com>
Date: Wed, 22 Oct 2014 11:33:52 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: myllynen@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsstat: fix server rpc stats header
References: <544499BA.1050408@redhat.com>
In-Reply-To: <544499BA.1050408@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/20/2014 01:12 AM, Marko Myllynen wrote:
> linux/net/sunrpc/stats.c has:
> 
> /*
>  * Get RPC server stats
>  */
> void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
> ...
>         seq_printf(seq,
>                 "rpc %u %u %u %u %u\n",
>                         statp->rpccnt,
>                         statp->rpcbadfmt+statp->rpcbadauth+statp->rpcbadclnt,
>                         statp->rpcbadfmt,
>                         statp->rpcbadauth,
>                         statp->rpcbadclnt);
> ...
> 
> But when /proc/net/rpc/nfsd contains
> 
> rpc 1 2 3 4 5
> 
> nfsstat -sv prints:
> 
> Server rpc stats:
> calls      badcalls   badclnt    badauth    xdrcall
> 1          2          3          4          5
> 
> Change this to match the kernel:
> 
> Server rpc stats:
> calls      badcalls   badfmt     badauth    badclnt
> 1          2          3          4          5
> 
> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1142842.
> 
> Signed-off-by: Marko Myllynen <myllynen@redhat.com>
Committed.... 

steved.

> ---
>  utils/nfsstat/nfsstat.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 18e4d27..9f481db 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -558,7 +558,7 @@ print_server_stats(int opt_prt)
>  			;
>  		} else {
>  			print_numbers(LABEL_srvrpc
> -				"calls      badcalls   badclnt    badauth    xdrcall\n",
> +				"calls      badcalls   badfmt     badauth    badclnt\n",
>  				srvrpcinfo, 5);
>  			printf("\n");
>  		}
> 
