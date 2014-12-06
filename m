Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaLFWYU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Dec 2014 17:24:20 -0500
Message-ID: <54838211.1070007@RedHat.com>
Date: Sat, 06 Dec 2014 17:24:17 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountstats: Sort RPC statistics by operation count
References: <20141104221043.13019.51333.stgit@manet.1015granger.net>
In-Reply-To: <20141104221043.13019.51333.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

First of all, my apologies for taking so long to get to this... 
 
On 11/04/2014 05:14 PM, Chuck Lever wrote:
> Sort the RPC statistics in descending order by operation count, so
> that the most frequently executed operation appears at the top of
> the listing (a la `top`).
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hey folks-
> 
> Any opinions about this? I considered adding a "--sort" command line
> option to enable sorting, but instead made it always-on.
> 
> Could also use --sort to specify which individual statistic is used
> for sorting (op count, RTT, retransmit rate, and so forth).
This is an interesting idea... But let me get in Scott's patches
and then we can build from there... 
 
> 
> Try: watch -d "mountstats --rpc /mnt/your-mount-here"
I had better luck with watch -n 0 "mountstats --rpc /mnt/your-mount-here"
But the output looks much better... Nice work!

Committed... 

steved.

>  1 file changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 9a6ec43..f75103c 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -24,6 +24,7 @@ MA 02110-1301 USA
>  """
>  
>  import sys, os, time
> +from operator import itemgetter
>  
>  Mountstats_version = '0.2'
>  
> @@ -262,27 +263,29 @@ class DeviceData:
>          """
>          sends = self.__rpc_data['rpcsends']
>  
> -        # XXX: these should be sorted by 'count'
> -        print()
> +        allstats = []
>          for op in self.__rpc_data['ops']:
> -            stats = self.__rpc_data[op]
> -            count = stats[0]
> -            retrans = stats[1] - count
> +            allstats.append([op] + self.__rpc_data[op])
> +
> +        print()
> +        for stats in sorted(allstats, key=itemgetter(1), reverse=True):
> +            count = stats[1]
>              if count != 0:
> -                print('%s:' % op)
> +                print('%s:' % stats[0])
>                  print('\t%d ops (%d%%)' % \
>                      (count, ((count * 100) / sends)), end=' ')
> +                retrans = stats[2] - count
>                  if retrans != 0:
>                      print('\t%d retrans (%d%%)' % (retrans, ((retrans * 100) / count)), end=' ')
> -                    print('\t%d major timeouts' % stats[2])
> +                    print('\t%d major timeouts' % stats[3])
>                  else:
>                      print('')
>                  print('\tavg bytes sent per op: %d\tavg bytes received per op: %d' % \
> -                    (stats[3] / count, stats[4] / count))
> -                print('\tbacklog wait: %f' % (float(stats[5]) / count), end=' ')
> -                print('\tRTT: %f' % (float(stats[6]) / count), end=' ')
> +                    (stats[4] / count, stats[5] / count))
> +                print('\tbacklog wait: %f' % (float(stats[6]) / count), end=' ')
> +                print('\tRTT: %f' % (float(stats[7]) / count), end=' ')
>                  print('\ttotal execute time: %f (milliseconds)' % \
> -                    (float(stats[7]) / count))
> +                    (float(stats[8]) / count))
>  
>      def compare_iostats(self, old_stats):
>          """Return the difference between two sets of stats
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
