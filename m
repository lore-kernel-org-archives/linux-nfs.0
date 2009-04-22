From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-iostat.py: Print Data Cache Statistics
Date: Wed, 22 Apr 2009 14:38:02 -0400
Message-ID: <DDDAA861-C6F3-4AE9-9130-ECE04B5790CF@oracle.com>
References: <8EF2000D-C4D6-4AC2-B37C-221594A515B4@oracle.com> <1240364531-11499-1-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:60672 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbZDVSiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 14:38:14 -0400
In-Reply-To: <1240364531-11499-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kevin-

On Apr 21, 2009, at 9:42 PM, Kevin Constantine wrote:
> I rolled the read cache, and write patches into a single patch below.
>
> add --data flag to print data cache statistics
> print read cache stats from __print_data_cache_stats
> print stats about bytes written by NFS
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
> >
> ---
> tools/nfs-iostat/nfs-iostat.py |   28 ++++++++++++++++++++++------
> 1 files changed, 22 insertions(+), 6 deletions(-)
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 9626d42..cb3da59 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -220,14 +220,22 @@ class DeviceData:
>         """Print the data cache hit rate
>         """
>         nfs_stats = self.__nfs_data
> -        app_bytes_read = float(nfs_stats['normalreadbytes'])
> +        app_bytes_read = float(nfs_stats['normalreadbytes'] +  
> nfs_stats['directreadbytes'])

Again, I object to this particular change.  The reason for the current  
computation is to retain precision and mitigate the chance of an  
overflow.  Reversing the sense of this computation (by introducing the  
addition above) increases the probability of overflow here.  Remember  
that over time, these numbers can grow exceptionally large.

If you think you need this change, you do need to provide some  
justification for the reorganization in the patch description.  Why is  
the current code inadequate?

>         if app_bytes_read != 0:
> -            client_bytes_read = float(nfs_stats['serverreadbytes']  
> - nfs_stats['directreadbytes'])
> -            ratio = ((app_bytes_read - client_bytes_read) * 100) /  
> app_bytes_read
> -
> +            cached_read_bytes = float(app_bytes_read -  
> float(nfs_stats['serverreadbytes']))
> +            ratio = (cached_read_bytes * 100) / app_bytes_read
>             print
> -            print 'app bytes: %f  client bytes %f' %  
> (app_bytes_read, client_bytes_read)
> -            print 'Data cache hit ratio: %4.2f%%' % ratio

In my opinion, displaying O_DIRECT reads right next to the cache hit  
ratio is deceptive.  This is why I did not include the O_DIRECT counts  
here.  They have no impact on the page cache hit ratio, as O_DIRECT  
data is never cached in the kernel.

> +            print '%10s %15s %15s %15s %7s' % ("Data Read:", "From  
> Server", "From Cache", "Total", "Hit %")
> +            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' % ("", \
> +	    					float(nfs_stats['serverreadbytes']) / 1024.0 / 1024.0, \
> +						cached_read_bytes / 1024.0 / 1024.0, \
> +						app_bytes_read / 1024.0 / 1024.0, \
> +						ratio)

If app_bytes_read is zero, we should print a line here that displays  
zeroes, as is done in other areas of this code.  I know that nfsstat  
quells output lines containing all zeros, but other tools (like  
iostat) do not.  What ends up happening is that when there is no I/O  
activity, no lines are produced at all.  That is confusing to users  
when nfs-iostat is in the "output one line every N seconds" mode.

> +        bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
> +	if bytes_written_by_nfs != 0:
> +	    print
> +            print '%13s %12s' % ("Data Written:", "To Server")
> +	    print '%10s %13.4fMB' % ("", bytes_written_by_nfs / 1024.0 /  
> 1024.0)

As you are not dividing by bytes_written_by_nfs, there is no  
particular reason to gate this output.  I don't see the need for the  
extra variable here either.  You don't have a similar variable in the  
read statistics, for example.

You included application and direct read bytes in your read  
statistics, but not here.  Why not?

>     def __print_attr_cache_stats(self, sample_time):
>         """Print attribute cache efficiency stats
> @@ -390,6 +398,10 @@ class DeviceData:
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
> @@ -487,6 +499,10 @@ def iostat_command(name):
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
