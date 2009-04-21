From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 1/2] nfs-iostat.py: Print Data Cache Statistics
Date: Tue, 21 Apr 2009 10:54:04 -0700
Message-ID: <49EE083C.6010105@disney.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com> <4EEE5CE8-9A51-4828-8B70-B48A35F46F01@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:38146 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbZDURyH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 13:54:07 -0400
In-Reply-To: <4EEE5CE8-9A51-4828-8B70-B48A35F46F01@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Apr 20, 2009, at 10:03 PM, Kevin Constantine wrote:
>> add --data flag to print data cache statistics
>> print read cache stats from __print_data_cache_stats
> 
> It's been a while since I wrote this code... comments below.
> 
>> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
>> ---
>> tools/nfs-iostat/nfs-iostat.py |   26 ++++++++++++++++++++------
>> 1 files changed, 20 insertions(+), 6 deletions(-)
>>
>> diff --git a/tools/nfs-iostat/nfs-iostat.py 
>> b/tools/nfs-iostat/nfs-iostat.py
>> index 9626d42..d331a72 100644
>> --- a/tools/nfs-iostat/nfs-iostat.py
>> +++ b/tools/nfs-iostat/nfs-iostat.py
>> @@ -220,14 +220,20 @@ class DeviceData:
>>         """Print the data cache hit rate
>>         """
>>         nfs_stats = self.__nfs_data
>> -        app_bytes_read = float(nfs_stats['normalreadbytes'])
>> +        app_bytes_read = float(nfs_stats['normalreadbytes'] + 
>> nfs_stats['directreadbytes'])
>>         if app_bytes_read != 0:
>> -            client_bytes_read = float(nfs_stats['serverreadbytes'] - 
>> nfs_stats['directreadbytes'])
>> -            ratio = ((app_bytes_read - client_bytes_read) * 100) / 
>> app_bytes_read
>> -
>> +            read_bytes_from_server = float(nfs_stats['serverreadbytes'])
>> +            directio_bytes_from_server = 
>> float(nfs_stats['directreadbytes'])
>> +            standard_read_bytes_from_server = read_bytes_from_server 
>> - directio_bytes_from_server
>> +            cached_read_bytes = float(app_bytes_read - 
>> read_bytes_from_server)
> 
> I'm not sure why you are reversing the sense of this computation.  
> "directreadbytes" is the count of bytes that applications read with 
> O_DIRECT.  These are never cached, but they are counted in 
> "serverreadbytes", so my logic subtracts them before computing the hit 
> ratio.  Was there some accounting problem you found?  (If there was, 
> it's worth stating that explicitly in the patch description).

Originally you had app_bytes_read = normalreadbytes, but that's not entirely true, since an app might be reading with 
O_DIRECT, therefore app_bytes_read should probably be normal + direct.

client_bytes_read seemed ambiguous to me, is that bytes being read by the host client from the server, bytes being read 
by the nfs client process?  read_bytes_from_server seemed more logical, but in the diff block below, I've removed that 
altogether, and am just left with cached_read_bytes.

> 
>> +            ratio = (cached_read_bytes / app_bytes_read) * 100
> 
> The other functions use (x * 100) / y -- I seem to recall there are 
> rounding errors if you do it the way you've done it here, but I don't 
> remember exactly what the issue was.  But you are changing this one so 
> it is different than the all the other similar computations.  Can you 
> state your reason?
> 

since cached_read_bytes = app_bytes_read - client_bytes_read, i used (cached_read_bytes / app_bytes_read) * 100, but 
that is the same as (cached_read_bytes * 100) / app_bytes_read if you'd rather see that.

new diff block below (if it all checks out, i'll send the whole patch, unless you'd rather just see that.)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 9626d42..7dae659 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -220,14 +220,17 @@ class DeviceData:
          """Print the data cache hit rate
          """
          nfs_stats = self.__nfs_data
-        app_bytes_read = float(nfs_stats['normalreadbytes'])
+        app_bytes_read = float(nfs_stats['normalreadbytes'] + nfs_stats['directreadbytes'])
          if app_bytes_read != 0:
-            client_bytes_read = float(nfs_stats['serverreadbytes'] - nfs_stats['directreadbytes'])
-            ratio = ((app_bytes_read - client_bytes_read) * 100) / app_bytes_read
-
+            cached_read_bytes = float(app_bytes_read - float(nfs_stats['serverreadbytes']))
+            ratio = (cached_read_bytes * 100) / app_bytes_read
              print
-            print 'app bytes: %f  client bytes %f' % (app_bytes_read, client_bytes_read)
-            print 'Data cache hit ratio: %4.2f%%' % ratio
+            print '%10s %15s %15s %15s %7s' % ("Data Read:", "From Server", "From Cache", "Total", "Hit %")
+            print '%10s %13.4fMB %13.4fMB %13.4fMB %6.2f%%' % ("", \
+                                               float(nfs_stats['serverreadbytes']) / 1024.0 / 1024.0, \
+                                               cached_read_bytes / 1024.0 / 1024.0, \
+                                               app_bytes_read / 1024.0 / 1024.0, \
+                                               ratio)

      def __print_attr_cache_stats(self, sample_time):
          """Print attribute cache efficiency stats

-kevin

> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
