From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-iostat.py: Print Data Cache Statistics
Date: Mon, 27 Apr 2009 11:33:02 -0400
Message-ID: <50DACB0A-59C3-4BCF-A470-AAB5525CEF26@oracle.com>
References: <8EF2000D-C4D6-4AC2-B37C-221594A515B4@oracle.com> <1240364531-11499-1-git-send-email-kevin.constantine@disneyanimation.com> <DDDAA861-C6F3-4AE9-9130-ECE04B5790CF@oracle.com> <49F28096.9060300@disney.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50585 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756624AbZD0PdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 11:33:18 -0400
In-Reply-To: <49F28096.9060300-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 24, 2009, at 11:16 PM, Kevin Constantine wrote:
> Chuck Lever wrote:
>> Hi Kevin-
>> On Apr 21, 2009, at 9:42 PM, Kevin Constantine wrote:
>>> I rolled the read cache, and write patches into a single patch  
>>> below.
>>>
>>> add --data flag to print data cache statistics
>>> print read cache stats from __print_data_cache_stats
>>> print stats about bytes written by NFS
>>>
>>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
>>> >
>>> ---
>>> tools/nfs-iostat/nfs-iostat.py |   28 ++++++++++++++++++++++------
>>> 1 files changed, 22 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
>>> iostat.py
>>> index 9626d42..cb3da59 100644
>>> --- a/tools/nfs-iostat/nfs-iostat.py
>>> +++ b/tools/nfs-iostat/nfs-iostat.py
>>> @@ -220,14 +220,22 @@ class DeviceData:
>>>        """Print the data cache hit rate
>>>        """
>>>        nfs_stats = self.__nfs_data
>>> -        app_bytes_read = float(nfs_stats['normalreadbytes'])
>>> +        app_bytes_read = float(nfs_stats['normalreadbytes'] +  
>>> nfs_stats['directreadbytes'])
>> Again, I object to this particular change.  The reason for the  
>> current computation is to retain precision and mitigate the chance  
>> of an overflow.  Reversing the sense of this computation (by  
>> introducing the addition above) increases the probability of  
>> overflow here.  Remember that over time, these numbers can grow  
>> exceptionally large.
>> If you think you need this change, you do need to provide some  
>> justification for the reorganization in the patch description.  Why  
>> is the current code inadequate?
>
> I've changed my opinion on how the cache hit ratio should be  
> computed and now agree with you.  I was thinking that direct reads  
> should negatively impact the ratio, but that doesn't make a whole  
> lot of sense.
>
>>>        if app_bytes_read != 0:
>>> -            client_bytes_read =  
>>> float(nfs_stats['serverreadbytes'] - nfs_stats['directreadbytes'])
>>> -            ratio = ((app_bytes_read - client_bytes_read) *  
>>> 100) / app_bytes_read
>>> -
>>> +            cached_read_bytes = float(app_bytes_read -  
>>> float(nfs_stats['serverreadbytes']))
>>> +            ratio = (cached_read_bytes * 100) / app_bytes_read
>>>            print
>>> -            print 'app bytes: %f  client bytes %f' %  
>>> (app_bytes_read, client_bytes_read)
>>> -            print 'Data cache hit ratio: %4.2f%%' % ratio
>> In my opinion, displaying O_DIRECT reads right next to the cache  
>> hit ratio is deceptive.  This is why I did not include the O_DIRECT  
>> counts here.  They have no impact on the page cache hit ratio, as  
>> O_DIRECT data is never cached in the kernel.
>
> I've changed the output considerably this time around.  I think it  
> makes more sense, let me know what you think.
>
> nani:/vol/pamtest mounted on /data/pamtest:
>
>   op/s         rpc bklog
> 3452.00           13.16
> read:             ops/s            kB/s           kB/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                3452.000        111407.906       32.273        0  
> (0.0%)           4.633           8.628
> write:            ops/s            kB/s           kB/op          
> retrans         avg RTT (ms)    avg exe (ms)
>                  0.000           0.000           0.000        0  
> (0.0%)           0.000           0.000
>
>           Network                                          Direct I/ 
> O             Direct %                  Total
>      Read        Write   Cache Reads    Cache Hit %     Read         
> Write       Read     Write         Read        Write
>  107.8750MB     0.0000MB     4.1236MB       3.68%     0.0000MB      
> 0.0000MB     0.00%     0.00%   111.9986MB     0.0000MB

This is a lot better, but I still find the placement of direct I/O  
statistics near the cache hit ratio confusing.  Direct reads are a  
totally different beast from normal (cached) reads.  I also think that  
read caching and write caching behavior are different enough that  
reporting them separately might be warranted.

It occurs to me that another important piece of information here is  
how often the NFS client decides it needs to invalidate page cache  
pages.  It doesn't invalidate individual pages; if a file's mtime has  
changed, the client purges all cached data for that file.  So, if the  
client has read the data in a page once already, but the cache was  
invalidated, it will read the same page again (whether data in the  
page has changed on the server or not).

I think it would be informative to provide at least the page cache  
invalidation number with the hit ratio, but it could also be  
interesting to see how often the same page is read multiple times.   
The kernel doesn't keep that stat at the moment.

Distinguishing between "cache missed because client had never read the  
page before" and "cache missed because client noticed the file  
changed" might be important, but it might also be difficult to track.   
For now, maybe the best approach is simply to report the page cache  
invalidation stat along with the computed hit ratio?

>>> +            print '%10s %15s %15s %15s %7s' % ("Data Read:",  
>>> "From Server", "From Cache", "Total", "Hit %")
>>> +            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' %  
>>> ("", \
>>> +                            float(nfs_stats['serverreadbytes']) /  
>>> 1024.0 / 1024.0, \
>>> +                        cached_read_bytes / 1024.0 / 1024.0, \
>>> +                        app_bytes_read / 1024.0 / 1024.0, \
>>> +                        ratio)
>> If app_bytes_read is zero, we should print a line here that  
>> displays zeroes, as is done in other areas of this code.  I know  
>> that nfsstat quells output lines containing all zeros, but other  
>> tools (like iostat) do not.  What ends up happening is that when  
>> there is no I/O activity, no lines are produced at all.  That is  
>> confusing to users when nfs-iostat is in the "output one line every  
>> N seconds" mode.
>
> Agreed.  It now prints out zeroes.  There are instances where data  
> has been
> sent through the NFS stack and counted in the serverbytes counter, but
> haven't made it through the userspace stack and haven't been counted  
> so we
> get a negative cache hit ratio. In these cases, I'm converting the  
> cache
> ratio and cache bytes to zero.

I don't see how this can happen.  All of the NFS I/O statistics are  
counted in the kernel; there is no "user space stack".  "normal" and  
"direct" are counted before the NFS client starts any network operation.

So, maybe there's a bug in the kernel accounting or reporting?  Or  
perhaps this behavior is exposed only on SMP?

>>> +        bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
>>> +    if bytes_written_by_nfs != 0:
>>> +        print
>>> +            print '%13s %12s' % ("Data Written:", "To Server")
>>> +        print '%10s %13.4fMB' % ("", bytes_written_by_nfs /  
>>> 1024.0 / 1024.0)
>> As you are not dividing by bytes_written_by_nfs, there is no  
>> particular reason to gate this output.  I don't see the need for  
>> the extra variable here either.  You don't have a similar variable  
>> in the read statistics, for example.
>
> I was thinking the gate was there to prevent non-zero values from  
> printing.
> This has been fixed.
>
>> You included application and direct read bytes in your read  
>> statistics, but not here.  Why not?
>
> The new output prints Network reads/writes, direct reads/writes, total
> reads/writes, cache reads, cache ratio and direct i/o ratios for  
> reads/writes.
>
> New Patch below:
>
> add --data flag to print data cache statistics
> --data flag prints Network reads/writes, cache reads, cache hit%,  
> Direct I/O reads/writes, Direct I/O% and Total reads/Writes
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
> >
> ---
> tools/nfs-iostat/nfs-iostat.py |   53 +++++++++++++++++++++++++++++++ 
> ++++++---
> 1 files changed, 49 insertions(+), 4 deletions(-)
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 9626d42..b9f3a96 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -220,14 +220,51 @@ class DeviceData:
>         """Print the data cache hit rate
>         """
>         nfs_stats = self.__nfs_data
> +	client_bytes_read = 0
> +	ratio = 0
> +	direct_read_ratio = 0
> +	direct_write_ratio = 0
> +
>         app_bytes_read = float(nfs_stats['normalreadbytes'])
> +        client_bytes_read = float(nfs_stats['serverreadbytes'] -  
> nfs_stats['directreadbytes'])
> +        direct_read_bytes = float(nfs_stats['directreadbytes'])
> +	direct_write_bytes = float(nfs_stats['directwritebytes'])
>         if app_bytes_read != 0:
> -            client_bytes_read = float(nfs_stats['serverreadbytes']  
> - nfs_stats['directreadbytes'])
>             ratio = ((app_bytes_read - client_bytes_read) * 100) /  
> app_bytes_read
> +        if direct_read_bytes != 0:
> +            direct_read_ratio = float(nfs_stats['directreadbytes'])  
> * 100 / \
> +				(app_bytes_read + direct_read_bytes)
> +        if direct_write_bytes != 0:
> +            direct_write_ratio =  
> float(nfs_stats['directwritebytes']) * 100 / \
> +				(direct_write_bytes + float(nfs_stats['normalwritebytes']))
> +
> +        network_reads_MB = float(nfs_stats['serverreadbytes']) /  
> 1024.0 / 1024.0
> +        network_writes_MB = float(nfs_stats['serverwritebytes']) /  
> 1024.0 / 1024.0
> +        cached_reads_MB = float(app_bytes_read -  
> client_bytes_read) / 1024.0 / 1024.0
> +        direct_reads_MB = float(nfs_stats['directreadbytes']) /  
> 1024.0 / 1024.0
> +        direct_writes_MB = float(nfs_stats['directwritebytes']) /  
> 1024.0 / 1024.0
> +        total_reads_MB = float(app_bytes_read +  
> nfs_stats['directreadbytes']) / 1024.0 / 1024.0
> +	total_writes_MB = float(nfs_stats['normalwritebytes'] +  
> nfs_stats['directwritebytes']) / \
> +			1024.0 / 1024.0

Just a nit: the indentation here is uneven.  Given this is Python,  
this could be a little more than just a cosmetic problem over the long  
run.

I always find it a challenge to avoid using tabs in Python scripts.

> +
> +        """ Bytes may have been counted by the NFS stack but  
> haven't been counted by the
> +            userspace stack.  When this happens, we see negative  
> cache values.  Set these
> +            to zero to avoid confusion.
> +        """
> +        if cached_reads_MB < 0:
> +            cached_reads_MB = 0;
> +        if ratio < 0:
> +            ratio = 0;
>
> -            print
> -            print 'app bytes: %f  client bytes %f' %  
> (app_bytes_read, client_bytes_read)
> -            print 'Data cache hit ratio: %4.2f%%' % ratio
> +        print
> +        print '%18s %51s %20s %22s' % ("Network", "Direct I/O",  
> "Direct %", "Total")
> +        print '%10s %12s %13s %14s %8s %12s %10s %9s %12s %12s' % \
> +		("Read", "Write", "Cache Reads", "Cache Hit %", "Read", "Write", \
> +		"Read", "Write",  "Read", "Write")
> +        print '%10.4fMB %10.4fMB %10.4fMB %10.2f%% %10.4fMB  
> %10.4fMB %8.2f%% %8.2f%% %10.4fMB %10.4fMB' % ( \
> +		network_reads_MB, network_writes_MB, cached_reads_MB, ratio,  
> direct_reads_MB, \
> +	 	direct_writes_MB, direct_read_ratio, direct_write_ratio,  
> total_reads_MB, \
> +		total_writes_MB)
>
>     def __print_attr_cache_stats(self, sample_time):
>         """Print attribute cache efficiency stats
> @@ -390,6 +427,10 @@ class DeviceData:
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
> @@ -487,6 +528,10 @@ def iostat_command(name):
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
> -- 1.6.2.1

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
