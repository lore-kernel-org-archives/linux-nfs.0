Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:24647 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754135AbZHZX4u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 19:56:50 -0400
Message-ID: <4A95CBDB.40502@dreamworks.com>
Date: Wed, 26 Aug 2009 16:57:15 -0700
From: Lans Carstensen <Lans.Carstensen@dreamworks.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] nfs-utils: nfs-iostat.py autofs cleanup and option
 to sort by ops/s
References: <4A94C13B.1070300@dreamworks.com> <486FBC5E-011A-4FF0-995D-944958BE74AE@oracle.com>
In-Reply-To: <486FBC5E-011A-4FF0-995D-944958BE74AE@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> 
> On Aug 26, 2009, at 12:59 AM, Lans Carstensen wrote:
> 
>> commit ef558b7b978418ac3da35e36dcf02a223e4ebe2d
>> Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
>> Date:   Tue Aug 25 21:52:49 2009 -0700
>>
>>    Update list of mount points to parse stats for and drop mount
>>    points from stats collection when they are umounted.  This
>>    ensures proper stats collection for autofs mountpoints.
>>
>> diff --git a/tools/nfs-iostat/nfs-iostat.py 
>> b/tools/nfs-iostat/nfs-iostat.py
>> index 6ce31fc..9f3b3eb 100644
>> --- a/tools/nfs-iostat/nfs-iostat.py
>> +++ b/tools/nfs-iostat/nfs-iostat.py
>> @@ -447,7 +447,14 @@ def parse_stats_file(filename):
>>     return ms_dict
>>
>> def print_iostat_summary(old, new, devices, time, ac):
>> -    for device in devices:
>> +    if old:
>> +        # Trim device list to only include intersection of old and 
>> new data,
>> +        # this addresses umounts due to autofs mountpoints
>> +        devicelist = filter(lambda x:x in devices,old)
>> +    else:
>> +        devicelist = devices
>> +
>> +    for device in devicelist:
>>         stats = DeviceData()
>>         stats.parse_stats(new[device])
>>         if not old:
>> @@ -458,11 +465,35 @@ def print_iostat_summary(old, new, devices, 
>> time, ac):
>>             diff_stats = stats.compare_iostats(old_stats)
>>             diff_stats.display_iostats(time, ac)
>>
>> +def list_nfs_mounts(givenlist, mountstats):
>> +    """return a list of NFS mounts given a list to validate or
>> +       return a full list if the given list is empty
>> +    """
>> +    list = []
>> +    if len(givenlist) > 0:
>> +        for device in givenlist:
>> +            stats = DeviceData()
>> +            stats.parse_stats(mountstats[device])
>> +            if stats.is_nfs_mountpoint():
>> +                list += [device]
>> +    else:
>> +        for device, descr in mountstats.iteritems():
>> +            stats = DeviceData()
>> +            stats.parse_stats(descr)
>> +            if stats.is_nfs_mountpoint():
>> +                list += [device]
>> +    if len(list) == 0:
>> +        print 'No NFS mount points were found'
>> +        return
> 
> You refactored this logic from the main routine.  I think this last 
> "return" was OK in the main routine, but in a subroutine it may not do 
> exactly what you want.  A NoneType object is passed to 
> print_iostat_summary in this case
> 
> [cel@matisse tmp]$ ./nfs-iostat.py
> No NFS mount points were found
> Traceback (most recent call last):
>   File "./nfs-iostat.py", line 580, in <module>
>     iostat_command(prog)
>   File "./nfs-iostat.py", line 549, in iostat_command
>     print_iostat_summary(old_mountstats, mountstats, devices, 
> sample_time, which)
>   File "./nfs-iostat.py", line 457, in print_iostat_summary
>     for device in devicelist:
> TypeError: 'NoneType' object is not iterable

Sigh.  Thanks.  I'll test more thoroughly and resubmit.  Based on the 
--list= argument change it'll probably be easier to refactor the script 
to use optparse, so I'll end up regenerating the last two patches as 
probably three new ones.

-- Lans Carstensen, Systems Engineering, Dreamworks Animation
Because they consistently observe and listen, the humble improve.
                                                -- Wynton Marsalis
