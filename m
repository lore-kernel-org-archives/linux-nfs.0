Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:55561 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394AbZD3OoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 10:44:06 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AFC18A07-15AC-46AF-902E-B702C29534FB@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
In-Reply-To: <49F9057F.40105@disney.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH] nfs-iostat.py: Print Data Cache Statistics
Date: Thu, 30 Apr 2009 10:43:43 -0400
References: <8EF2000D-C4D6-4AC2-B37C-221594A515B4@oracle.com> <1240364531-11499-1-git-send-email-kevin.constantine@disneyanimation.com> <DDDAA861-C6F3-4AE9-9130-ECE04B5790CF@oracle.com> <49F28096.9060300@disney.com> <50DACB0A-59C3-4BCF-A470-AAB5525CEF26@oracle.com> <49F9057F.40105@disney.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Kevin-

Thanks for sticking with this.

On Apr 29, 2009, at 9:57 PM, Kevin Constantine wrote:
> Chuck Lever wrote:
>> On Apr 24, 2009, at 11:16 PM, Kevin Constantine wrote:
>>> Chuck Lever wrote:
>>>> Hi Kevin-
>>>> On Apr 21, 2009, at 9:42 PM, Kevin Constantine wrote:
>>>>> I rolled the read cache, and write patches into a single patch  
>>>>> below.
>>>>>
>>>>> add --data flag to print data cache statistics
>>>>> print read cache stats from __print_data_cache_stats
>>>>> print stats about bytes written by NFS
>>>>>
>>>>> Signed-off-by: Kevin Constantine <kevin.constantine@disneyanimation.com 
>>>>> >
>>>>> ---
>>>>> tools/nfs-iostat/nfs-iostat.py |   28 ++++++++++++++++++++++------
>>>>> 1 files changed, 22 insertions(+), 6 deletions(-)
>>>>>
>>>>> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/ 
>>>>> nfs-iostat.py
>>>>> index 9626d42..cb3da59 100644
>>>>> --- a/tools/nfs-iostat/nfs-iostat.py
>>>>> +++ b/tools/nfs-iostat/nfs-iostat.py
>>>>> @@ -220,14 +220,22 @@ class DeviceData:
>>>>>       """Print the data cache hit rate
>>>>>       """
>>>>>       nfs_stats = self.__nfs_data
>>>>> -        app_bytes_read = float(nfs_stats['normalreadbytes'])
>>>>> +        app_bytes_read = float(nfs_stats['normalreadbytes'] +  
>>>>> nfs_stats['directreadbytes'])
>>>> Again, I object to this particular change.  The reason for the  
>>>> current computation is to retain precision and mitigate the  
>>>> chance of an overflow.  Reversing the sense of this computation  
>>>> (by introducing the addition above) increases the probability of  
>>>> overflow here.  Remember that over time, these numbers can grow  
>>>> exceptionally large.
>>>> If you think you need this change, you do need to provide some  
>>>> justification for the reorganization in the patch description.   
>>>> Why is the current code inadequate?
>>>
>>> I've changed my opinion on how the cache hit ratio should be  
>>> computed and now agree with you.  I was thinking that direct reads  
>>> should negatively impact the ratio, but that doesn't make a whole  
>>> lot of sense.
>>>
>>>>>       if app_bytes_read != 0:
>>>>> -            client_bytes_read =  
>>>>> float(nfs_stats['serverreadbytes'] - nfs_stats['directreadbytes'])
>>>>> -            ratio = ((app_bytes_read - client_bytes_read) *  
>>>>> 100) / app_bytes_read
>>>>> -
>>>>> +            cached_read_bytes = float(app_bytes_read -  
>>>>> float(nfs_stats['serverreadbytes']))
>>>>> +            ratio = (cached_read_bytes * 100) / app_bytes_read
>>>>>           print
>>>>> -            print 'app bytes: %f  client bytes %f' %  
>>>>> (app_bytes_read, client_bytes_read)
>>>>> -            print 'Data cache hit ratio: %4.2f%%' % ratio
>>>> In my opinion, displaying O_DIRECT reads right next to the cache  
>>>> hit ratio is deceptive.  This is why I did not include the  
>>>> O_DIRECT counts here.  They have no impact on the page cache hit  
>>>> ratio, as O_DIRECT data is never cached in the kernel.
>>>
>>> I've changed the output considerably this time around.  I think it  
>>> makes more sense, let me know what you think.
>>>
>>> nani:/vol/pamtest mounted on /data/pamtest:
>>>
>>>  op/s         rpc bklog
>>> 3452.00           13.16
>>> read:             ops/s            kB/s           kB/op          
>>> retrans         avg RTT (ms)    avg exe (ms)
>>>               3452.000        111407.906       32.273        0  
>>> (0.0%)           4.633           8.628
>>> write:            ops/s            kB/s           kB/op          
>>> retrans         avg RTT (ms)    avg exe (ms)
>>>                 0.000           0.000           0.000        0  
>>> (0.0%)           0.000           0.000
>>>
>>>          Network                                          Direct I/ 
>>> O             Direct %                  Total
>>>     Read        Write   Cache Reads    Cache Hit %     Read         
>>> Write       Read     Write         Read        Write
>>> 107.8750MB     0.0000MB     4.1236MB       3.68%     0.0000MB      
>>> 0.0000MB     0.00%     0.00%   111.9986MB     0.0000MB
>> This is a lot better, but I still find the placement of direct I/O  
>> statistics near the cache hit ratio confusing.  Direct reads are a  
>> totally different beast from normal (cached) reads.
>
> The goal of this output is to display what kind of I/O the client is
> performing, and where that data is coming from (be it over the  
> network,
> or from cache).  I'm not particularly attached to keeping the direct
> stats in there, I just figured that it's useful to know that, for
> example, 100MB of the 112MB can be attributed to direct i/o.  I've
> pulled the direct i/o stuff out.

I didn't mean for you to pull the direct I/O report out.  I think that  
information is useful, as you do.  But perhaps it could be displayed  
separately (like on a separate line).

> The new output looks like:
>
>            
> Network 
>                                                                 Total
>      Read        Write    Cache Reads    Cache Hit %    
> Invalidations       Read        Write
> 3585.4648MB     0.0000MB   606.5352MB         14.47%                
> 1  4192.0000MB     0.0000MB
>
>> I also think that read caching and write caching behavior are  
>> different enough that reporting them separately might be warranted.
>
> Are you suggesting that instead of printing out Network Reads/writes,
> instead there is a way to print out just reads, and just writes?  I  
> guess
> I'm a little confused by this.

Again, I was thinking of separate lines.  I'm just commenting on how  
the report is visually organized.

  o  We have normal reads, which go through the cache.  The  
interesting numbers are cache hit ratio, and data cache  
invalidations.  (And maybe read-ahead... see below).

  o  We have direct reads, which don't touch the page cache at all,  
and go right to the server

  o  We have normal writes, which are often combined by the client,  
and can sit in the page cache for a while.  An interesting statistic  
here would be how often the client is forced to flush the write cache  
via memory pressure, fsync(2) or close(2).

  o  We have direct writes, which go right to the server.

  o  We have the amount of data that actually appeared on the wire at  
some point.

Maybe you can report the raw I/O numbers (network, cached, direct  
reads and writes) on one line, and the page cache effectiveness data  
on a separate line?  Or perhaps reads on one line, and writes on  
another, since read caching is a different process than write  
gathering?  Or, perhaps you could provide a new command line option to  
display the direct I/O report?

>> It occurs to me that another important piece of information here is  
>> how often the NFS client decides it needs to invalidate page cache  
>> pages.  It doesn't invalidate individual pages; if a file's mtime  
>> has changed, the client purges all cached data for that file.  So,  
>> if the client has read the data in a page once already, but the  
>> cache was invalidated, it will read the same page again (whether  
>> data in the page has changed on the server or not).
>> I think it would be informative to provide at least the page cache  
>> invalidation number with the hit ratio, but it could also be  
>> interesting to see how often the same page is read multiple times.   
>> The kernel doesn't keep that stat at the moment.
>> Distinguishing between "cache missed because client had never read  
>> the page before" and "cache missed because client noticed the file  
>> changed" might be important, but it might also be difficult to  
>> track.  For now,
>> maybe the best approach is simply to report the page cache  
>> invalidation stat along with the computed hit ratio?
>
> I've printed out the datainvalidate counter, which, as far as I can
> tell, is the correct counter.

Yeah, I think that's correct.

>>>>> +            print '%10s %15s %15s %15s %7s' % ("Data Read:",  
>>>>> "From Server", "From Cache", "Total", "Hit %")
>>>>> +            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' %  
>>>>> ("", \
>>>>> +                             
>>>>> float(nfs_stats['serverreadbytes']) / 1024.0 / 1024.0, \
>>>>> +                        cached_read_bytes / 1024.0 / 1024.0, \
>>>>> +                        app_bytes_read / 1024.0 / 1024.0, \
>>>>> +                        ratio)
>>>> If app_bytes_read is zero, we should print a line here that  
>>>> displays zeroes, as is done in other areas of this code.  I know  
>>>> that nfsstat quells output lines containing all zeros, but other  
>>>> tools (like iostat) do not.  What ends up happening is that when  
>>>> there is no I/O activity, no lines are produced at all.  That is  
>>>> confusing to users when nfs-iostat is in the "output one line  
>>>> every N seconds" mode.
>>>
>>> Agreed.  It now prints out zeroes.  There are instances where data  
>>> has been
>>> sent through the NFS stack and counted in the serverbytes counter,  
>>> but
>>> haven't made it through the userspace stack and haven't been  
>>> counted so we
>>> get a negative cache hit ratio. In these cases, I'm converting the  
>>> cache
>>> ratio and cache bytes to zero.
>> I don't see how this can happen.  All of the NFS I/O statistics are  
>> counted in the kernel; there is no "user space stack".  "normal"  
>> and "direct" are counted before the NFS client starts any network  
>> operation.
>> So, maybe there's a bug in the kernel accounting or reporting?  Or  
>> perhaps this behavior is exposed only on SMP?
>
>
> As an example: I mounted a volume, and began a sequential read.  The
> mountstats proc file bytes counter looks like:
>
> 486533058 0 0 0 487096320 0 118920 0
>
> According to this, I've read more from the server than my application
> has asked for.  Because we calculate cached_byes as  
> application_bytes -
> server_bytes, we end up with a negative value.

Oh.  That's because of read-ahead.  So, _that_ would be a good reason  
to compute the read stats without subtraction!  :-)

Actually read-ahead effectiveness is about as interesting as page  
cache hit ratio.  If the client is reading too much (ie not using a  
lot of what was read from the server), that can have impact on server  
scalability.

We have counters that count the number of bytes that were read and  
written by the VFS (readpages and writepages).  This would be the  
number of bytes that were requested by normal cached reads and writes  
that were not already available in the page cache.  That gets rid of  
that subtraction, but perhaps doesn't get us a more accurate cache hit  
ratio.

I'll have to think about this.  We need additional counters in the  
kernel to sort this, but given the way the VFS is architected I don't  
immediately see an easy direct way to acquire this data.

>>>>> +        bytes_written_by_nfs =  
>>>>> float(nfs_stats['serverwritebytes'])
>>>>> +    if bytes_written_by_nfs != 0:
>>>>> +        print
>>>>> +            print '%13s %12s' % ("Data Written:", "To Server")
>>>>> +        print '%10s %13.4fMB' % ("", bytes_written_by_nfs /  
>>>>> 1024.0 / 1024.0)
>>>> As you are not dividing by bytes_written_by_nfs, there is no  
>>>> particular reason to gate this output.  I don't see the need for  
>>>> the extra variable here either.  You don't have a similar  
>>>> variable in the read statistics, for example.
>>>
>>> I was thinking the gate was there to prevent non-zero values from  
>>> printing.
>>> This has been fixed.
>>>
>>>> You included application and direct read bytes in your read  
>>>> statistics, but not here.  Why not?
>>>
>>> The new output prints Network reads/writes, direct reads/writes,  
>>> total
>>> reads/writes, cache reads, cache ratio and direct i/o ratios for  
>>> reads/writes.
>>>
>>> New Patch below:
>
> [...]
>
>>> nfs_stats['directreadbytes']) / 1024.0 / 1024.0
>>> +    total_writes_MB = float(nfs_stats['normalwritebytes'] +  
>>> nfs_stats['directwritebytes']) / \
>>> +            1024.0 / 1024.0
>> Just a nit: the indentation here is uneven.  Given this is Python,  
>> this could be a little more than just a cosmetic problem over the  
>> long run.
>
> fixed
>
>> I always find it a challenge to avoid using tabs in Python scripts.
>
> Out of curiosity, why were nfs-iostats.py and mountstats.py written in
> python instead of c like the rest of nfs-utils?

I wrote them as a quick prototype for testing while I was developing  
the kernel parts.  Since Red Hat has been providing some system  
utilities in Python for a while, we thought we might keep the  
prototypes and develop them into full-fledged tools for users.  We've  
also considered re-implementing these in C.

No-one has had time in a couple of years to look into this, though.   
It's still a work in progress.

>>> +
>>> +        """ Bytes may have been counted by the NFS stack but  
>>> haven't been counted by the
> [...]
>
> The next iteration of the patch below:
>
>
> add --data flag to print data cache statistics
>
> --data flag prints Network reads/writes, cache reads, cache hit%,  
> Cache invalidation count, Total reads/Writes
>
> Signed-off-by: Kevin Constantine <kevin.constantine@disneyanimation.com 
> >
> ---
> tools/nfs-iostat/nfs-iostat.py |   43 +++++++++++++++++++++++++++++++ 
> +++++---
> 1 files changed, 39 insertions(+), 4 deletions(-)
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 9626d42..e8bb2fb 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -220,14 +220,41 @@ class DeviceData:
>         """Print the data cache hit rate
>         """
>         nfs_stats = self.__nfs_data
> +        client_bytes_read = 0
> +        ratio = 0
> +        direct_read_ratio = 0
> +        direct_write_ratio = 0
> +
>         app_bytes_read = float(nfs_stats['normalreadbytes'])
> +        client_bytes_read = float(nfs_stats['serverreadbytes'] -  
> nfs_stats['directreadbytes'])
> +        direct_read_bytes = float(nfs_stats['directreadbytes'])
> +        direct_write_bytes = float(nfs_stats['directwritebytes'])
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
> +        total_writes_MB = float(nfs_stats['normalwritebytes'] +  
> nfs_stats['directwritebytes']) / \
> +			1024.0 / 1024.0
>
> -            print
> -            print 'app bytes: %f  client bytes %f' %  
> (app_bytes_read, client_bytes_read)
> -            print 'Data cache hit ratio: %4.2f%%' % ratio
> +        print
> +        print '%18s %68s' % ("Network", "Total")
> +        print '%10s %12s %14s %14s %15s %10s %12s' % \
> +		("Read", "Write", "Cache Reads", "Cache Hit %", \
> +		"Invalidations", "Read", "Write")
> +        print '%10.4fMB %10.4fMB %10.4fMB %13.2f%% %15d %10.4fMB  
> %10.4fMB' % ( \
> +		network_reads_MB, network_writes_MB, cached_reads_MB, ratio, \
> +	 	nfs_stats['datainvalidates'], total_reads_MB, total_writes_MB)
>
>     def __print_attr_cache_stats(self, sample_time):
>         """Print attribute cache efficiency stats
> @@ -390,6 +417,10 @@ class DeviceData:
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
> @@ -487,6 +518,10 @@ def iostat_command(name):
>         if arg in ['-p', '--page']:
>             which = 3
>             continue
> +	
> +        if arg in ['--data']:
> +            which = 4
> +            continue
>
>         if arg == sys.argv[0]:
>             continue
> -- 
> 1.6.2.1

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
