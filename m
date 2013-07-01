Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab3GAQD7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 12:03:59 -0400
Message-ID: <51D1A86D.7050904@RedHat.com>
Date: Mon, 01 Jul 2013 12:03:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsiostat: restore output format
References: <1371653913-1697-1-git-send-email-dros@netapp.com>
In-Reply-To: <1371653913-1697-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/06/13 10:58, Weston Andros Adamson wrote:
> recent changes to support python 3 changed the output of nfsiostat from:
> 
> read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
>                  48.094         2889.133         60.072        0 (0.0%)         177.160         184.833
> ...
> 
> to:
> 
> read:
>   ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe (ms)
> 		  0.000
> 	  0.000
> 	  0.000
>        0 (0.0%)
> 	  0.000
> 	  0.000
> ...
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Committed! 

steved.

> ---
>  tools/nfs-iostat/nfs-iostat.py | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index dfbef87..c035537 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -353,14 +353,14 @@ class DeviceData:
>              exe_per_op = 0.0
>  
>          op += ':'
> -        print('%s' % op.lower().ljust(15))
> +        print('%s' % op.lower().ljust(15), end='')
>          print('  ops/s\t\t   kB/s\t\t  kB/op\t\tretrans\t\tavg RTT (ms)\tavg exe (ms)')
>  
> -        print('\t\t%7.3f' % (ops / sample_time))
> -        print('\t%7.3f' % (kilobytes / sample_time))
> -        print('\t%7.3f' % kb_per_op)
> -        print(' %7d (%3.1f%%)' % (retrans, retrans_percent))
> -        print('\t%7.3f' % rtt_per_op)
> +        print('\t\t%7.3f' % (ops / sample_time), end='')
> +        print('\t%7.3f' % (kilobytes / sample_time), end='')
> +        print('\t%7.3f' % kb_per_op, end='')
> +        print(' %7d (%3.1f%%)' % (retrans, retrans_percent), end='')
> +        print('\t%7.3f' % rtt_per_op, end='')
>          print('\t%7.3f' % exe_per_op)
>  
>      def ops(self, sample_time):
> @@ -392,7 +392,7 @@ class DeviceData:
>          print()
>  
>          print('   op/s\t\trpc bklog')
> -        print('%7.2f' % (sends / sample_time))
> +        print('%7.2f' % (sends / sample_time), end='')
>          print('\t%7.2f' % backlog)
>  
>          if which == 0:
> 
