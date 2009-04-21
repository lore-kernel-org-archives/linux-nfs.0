From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] nfs-iostat.py: Added bytes written output
Date: Tue, 21 Apr 2009 15:00:41 -0400
Message-ID: <981BA943-47FA-433D-A762-B83983E6532A@oracle.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-3-git-send-email-kevin.constantine@disneyanimation.com> <ABA1CFF5-7104-4ADD-9847-F6B9136D9987@oracle.com> <49EE0901.2040704@disney.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:41413 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbZDUUGU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 16:06:20 -0400
In-Reply-To: <49EE0901.2040704-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 21, 2009, at 1:57 PM, Kevin Constantine wrote:
> Chuck Lever wrote:
>> On Apr 20, 2009, at 10:03 PM, Kevin Constantine wrote:
>>> Print statistics about bytes written by NFS
>>>
>>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
>>> >
>>> ---
>>> tools/nfs-iostat/nfs-iostat.py |   10 ++++++++++
>>> 1 files changed, 10 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
>>> iostat.py
>>> index d331a72..5f2e232 100644
>>> --- a/tools/nfs-iostat/nfs-iostat.py
>>> +++ b/tools/nfs-iostat/nfs-iostat.py
>>> @@ -221,6 +221,7 @@ class DeviceData:
>>>        """
>>>        nfs_stats = self.__nfs_data
>>>        app_bytes_read = float(nfs_stats['normalreadbytes'] +  
>>> nfs_stats['directreadbytes'])
>>> +        bytes_written_by_app =  
>>> float(nfs_stats['normalwritebytes'] + nfs_stats['directwritebytes'])
>>>        if app_bytes_read != 0:
>>>            read_bytes_from_server =  
>>> float(nfs_stats['serverreadbytes'])
>>>            directio_bytes_from_server =  
>>> float(nfs_stats['directreadbytes'])
>>> @@ -234,6 +235,15 @@ class DeviceData:
>>>                        cached_read_bytes / 1024.0 / 1024.0, \
>>>                        app_bytes_read / 1024.0 / 1024.0, \
>>>                        ratio)
>>> +    if bytes_written_by_app != 0:
>>> +        bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
>>> +        cached_write_bytes = float(bytes_written_by_app -  
>>> bytes_written_by_nfs);
>> Again, I don't see why this computation is necessary:  The  
>> "normalwritebytes" statistic is what was written through the  
>> client's cache, and "directwritebytes" counts the number of bytes  
>> that were written via O_DIRECT.
>
> As I said in the email preceding these patches:
> "I'm not quire sure about this patch.  I'm seeing oddities where the  
> number of bytes in "NORMALWRITTENBYTES + DIRECTWRITTENBYTES" does  
> not equal SERVERWRITTENBYTES.  In some cases the amount of data  
> written by the app (normalwrittenbytes + directwrittenbytes) is  
> greater than the amount of data written to the server, and in other  
> cases it's less than the amount of data written to the server.  At  
> the moment, i've ascribed that difference to data being written to  
> the local cache and not flushed, but that doesn't make a whole lot  
> of sense."

Our e-mail system may have barfed on my earlier reply, but I would  
like to understand why you need this statistic.  What kind of analysis  
are you looking for on the write side?

>
>>> +        print
>>> +            print '%13s %12s %15s %15s' % ("Data Written:", "To  
>>> Server", "To Cache", "Total")
>>> +        print '%10s %13.4fMB %13.4fMB %13.4fMB' % ("", \
>>> +                            bytes_written_by_nfs / 1024.0 /  
>>> 1024.0, \
>>> +                        cached_write_bytes / 1024.0 / 1024.0, \
>>> +                        bytes_written_by_app / 1024.0 / 1024.0)
>>>
>>>    def __print_attr_cache_stats(self, sample_time):
>>>        """Print attribute cache efficiency stats

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
