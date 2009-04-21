From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] nfs-iostat.py: Print Data Cache Statistics
Date: Tue, 21 Apr 2009 10:26:07 -0400
Message-ID: <4EEE5CE8-9A51-4828-8B70-B48A35F46F01@oracle.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:42227 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985AbZDUO1E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 10:27:04 -0400
In-Reply-To: <1240279414-30528-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 20, 2009, at 10:03 PM, Kevin Constantine wrote:
> add --data flag to print data cache statistics
> print read cache stats from __print_data_cache_stats

It's been a while since I wrote this code... comments below.

> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
> >
> ---
> tools/nfs-iostat/nfs-iostat.py |   26 ++++++++++++++++++++------
> 1 files changed, 20 insertions(+), 6 deletions(-)
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 9626d42..d331a72 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -220,14 +220,20 @@ class DeviceData:
>         """Print the data cache hit rate
>         """
>         nfs_stats = self.__nfs_data
> -        app_bytes_read = float(nfs_stats['normalreadbytes'])
> +        app_bytes_read = float(nfs_stats['normalreadbytes'] +  
> nfs_stats['directreadbytes'])
>         if app_bytes_read != 0:
> -            client_bytes_read = float(nfs_stats['serverreadbytes']  
> - nfs_stats['directreadbytes'])
> -            ratio = ((app_bytes_read - client_bytes_read) * 100) /  
> app_bytes_read
> -
> +            read_bytes_from_server =  
> float(nfs_stats['serverreadbytes'])
> +            directio_bytes_from_server =  
> float(nfs_stats['directreadbytes'])
> +            standard_read_bytes_from_server =  
> read_bytes_from_server - directio_bytes_from_server
> +            cached_read_bytes = float(app_bytes_read -  
> read_bytes_from_server)

I'm not sure why you are reversing the sense of this computation.   
"directreadbytes" is the count of bytes that applications read with  
O_DIRECT.  These are never cached, but they are counted in  
"serverreadbytes", so my logic subtracts them before computing the hit  
ratio.  Was there some accounting problem you found?  (If there was,  
it's worth stating that explicitly in the patch description).

> +            ratio = (cached_read_bytes / app_bytes_read) * 100

The other functions use (x * 100) / y -- I seem to recall there are  
rounding errors if you do it the way you've done it here, but I don't  
remember exactly what the issue was.  But you are changing this one so  
it is different than the all the other similar computations.  Can you  
state your reason?

>             print
> -            print 'app bytes: %f  client bytes %f' %  
> (app_bytes_read, client_bytes_read)
> -            print 'Data cache hit ratio: %4.2f%%' % ratio
> +            print '%10s %15s %15s %15s %7s' % ("Data Read:", "From  
> Server", "From Cache", "Total", "Hit %")
> +            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' % ("", \
> +	    					read_bytes_from_server / 1024.0 / 1024.0, \
> +						cached_read_bytes / 1024.0 / 1024.0, \
> +						app_bytes_read / 1024.0 / 1024.0, \
> +						ratio)
>
>     def __print_attr_cache_stats(self, sample_time):
>         """Print attribute cache efficiency stats
> @@ -390,6 +396,10 @@ class DeviceData:
>             self.__print_rpc_op_stats('READ', sample_time)
>             self.__print_rpc_op_stats('WRITE', sample_time)
>             self.__print_page_stats(sample_time)
> +        elif which == 4:
> +            self.__print_rpc_op_stats('READ', sample_time)
> +            self.__print_rpc_op_stats('WRITE', sample_time)
> +            self.__print_data_cache_stats()
>
> #
> # Functions
> @@ -487,6 +497,10 @@ def iostat_command(name):
>         if arg in ['-p', '--page']:
>             which = 3
>             continue
> +	
> +	if arg in ['--data']:
> +	    which = 4
> +	    continue
>
>         if arg == sys.argv[0]:
>             continue

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
