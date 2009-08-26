Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:55345 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361AbZHZObb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 10:31:31 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <2E466A37-7B26-4434-94AC-F17AD3FC606C@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Lans Carstensen <Lans.Carstensen@dreamworks.com>
In-Reply-To: <4A94C13B.1070300@dreamworks.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 3/4] nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
Date: Wed, 26 Aug 2009 10:30:27 -0400
References: <4A94C13B.1070300@dreamworks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'd like to try this one out so I'm sure I understand what's going on.

On Aug 26, 2009, at 12:59 AM, Lans Carstensen wrote:

> commit ef558b7b978418ac3da35e36dcf02a223e4ebe2d
> Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
> Date:   Tue Aug 25 21:52:49 2009 -0700
>
>    Update list of mount points to parse stats for and drop mount
>    points from stats collection when they are umounted.  This
>    ensures proper stats collection for autofs mountpoints.
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index 6ce31fc..9f3b3eb 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -447,7 +447,14 @@ def parse_stats_file(filename):
>     return ms_dict
>
> def print_iostat_summary(old, new, devices, time, ac):
> -    for device in devices:
> +    if old:
> +        # Trim device list to only include intersection of old and  
> new data,
> +        # this addresses umounts due to autofs mountpoints
> +        devicelist = filter(lambda x:x in devices,old)
> +    else:
> +        devicelist = devices
> +
> +    for device in devicelist:
>         stats = DeviceData()
>         stats.parse_stats(new[device])
>         if not old:
> @@ -458,11 +465,35 @@ def print_iostat_summary(old, new, devices,  
> time, ac):
>             diff_stats = stats.compare_iostats(old_stats)
>             diff_stats.display_iostats(time, ac)
>
> +def list_nfs_mounts(givenlist, mountstats):
> +    """return a list of NFS mounts given a list to validate or
> +       return a full list if the given list is empty
> +    """
> +    list = []
> +    if len(givenlist) > 0:
> +        for device in givenlist:
> +            stats = DeviceData()
> +            stats.parse_stats(mountstats[device])
> +            if stats.is_nfs_mountpoint():
> +                list += [device]
> +    else:
> +        for device, descr in mountstats.iteritems():
> +            stats = DeviceData()
> +            stats.parse_stats(descr)
> +            if stats.is_nfs_mountpoint():
> +                list += [device]
> +    if len(list) == 0:
> +        print 'No NFS mount points were found'
> +        return
> +
> +    return list
> +
> def iostat_command(name):
>     """iostat-like command for NFS mount points
>     """
>     mountstats = parse_stats_file('/proc/self/mountstats')
>     devices = []
> +    origdevices = []
>     which = 0
>     interval_seen = False
>     count_seen = False
> @@ -492,7 +523,7 @@ def iostat_command(name):
>             continue
>
>         if arg in mountstats:
> -            devices += [arg]
> +            origdevices += [arg]
>         elif not interval_seen:
>             interval = int(arg)
>             if interval > 0:
> @@ -509,23 +540,7 @@ def iostat_command(name):
>                 return
>
>     # make certain devices contains only NFS mount points
> -    if len(devices) > 0:
> -        check = []
> -        for device in devices:
> -            stats = DeviceData()
> -            stats.parse_stats(mountstats[device])
> -            if stats.is_nfs_mountpoint():
> -                check += [device]
> -        devices = check
> -    else:
> -        for device, descr in mountstats.iteritems():
> -            stats = DeviceData()
> -            stats.parse_stats(descr)
> -            if stats.is_nfs_mountpoint():
> -                devices += [device]
> -    if len(devices) == 0:
> -        print 'No NFS mount points were found'
> -        return
> +    devices = list_nfs_mounts(origdevices, mountstats)
>
>     old_mountstats = None
>     sample_time = 0.0
> @@ -541,6 +556,9 @@ def iostat_command(name):
>             time.sleep(interval)
>             sample_time = interval
>             mountstats = parse_stats_file('/proc/self/mountstats')
> +            # automount mountpoints add and drop, if automount is  
> involved
> +            # we need to recheck the devices list when reparsing
> +            devices = list_nfs_mounts(origdevices,mountstats)
>             count -= 1
>     else:
>         while True:
> @@ -549,6 +567,9 @@ def iostat_command(name):
>             time.sleep(interval)
>             sample_time = interval
>             mountstats = parse_stats_file('/proc/self/mountstats')
> +            # automount mountpoints add and drop, if automount is  
> involved
> +            # we need to recheck the devices list when reparsing
> +            devices = list_nfs_mounts(origdevices,mountstats)
>
> #
> # Main
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



