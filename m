Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21308 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250AbZHYRIW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 13:08:22 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <009376AC-B08B-4E90-A46B-E5BC069A5A78@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Lans Carstensen <Lans.Carstensen@dreamworks.com>
In-Reply-To: <4A93214A.5000404@dreamworks.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [NFS] [PATCH] nfs-utils: nfs-iostat.py option to sort by ops/s
Date: Tue, 25 Aug 2009 12:29:18 -0400
References: <4A93214A.5000404@dreamworks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[ Cc: changed to correct mailing list.  sf.net list is deprecated. ]

On Aug 24, 2009, at 7:24 PM, Lans Carstensen wrote:
> Hi,
>
> I've recently made tools/nfs-iostat/nfs-iostat.py more useful in our  
> autofs environment with a variety of cleanups and am offering this  
> patch up for discussion and/or inclusion in nfs-utils.  It does the  
> following:
>
> * Adds a --top flag to sort the display of mountpoint entries by ops/ 
> s.
> * Adds a --<n> flag to only display stats for the first <n>  
> mountpoints
> * Re-reads the mountpoint list on intervals since it's dynamic in an
>  autofs environment.
> * Conforms the Python path to the LSB 3.2+ standard of /usr/bin/python
> http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages/pylocation.html

A couple of overall comments.

1.  These seem to be logically independent changes, so we would prefer  
them in separate patches.  Each logical change can be refined and  
voted up or down separately.

2.  Sorting by ops is OK, but not sure about "--top".  Since the  
script doesn't generate a curses like display like "top" does, maybe  
"--sort <n>" would be a better name, and --top and --<n> could be  
combined.

3.  The distributors should weigh in on the Python path change.

4.  I need to re-read the code to understand how the looping is done.   
Naturally we do want to keep up to date after a mount or umount  
occurs, but I thought it already did that.  I'll try to apply the  
patch this afternoon and test it out.

>
> My ml subscription is still pending, so make sure this email is  
> cc'ed on feedback.  Thank you.
>
> -- Lans Carstensen
> --- tools/nfs-iostat/nfs-iostat.py.orig	2009-08-24  
> 15:52:26.000000000 -0700
> +++ tools/nfs-iostat/nfs-iostat.py	2009-08-24 15:53:11.000000000 -0700
> @@ -1,4 +1,4 @@
> -#!/usr/bin/env python
> +#!/usr/bin/python
> # -*- python-mode -*-
> """Emulate iostat for NFS mount points using /proc/self/mountstats
> """
> @@ -20,9 +20,9 @@
> Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  
> USA
> """
>
> -import sys, os, time
> +import sys, os, time, re
>
> -Iostats_version = '0.2'
> +Iostats_version = '0.3'
>
> def difference(x, y):
>     """Used for a map() function
> @@ -353,6 +353,13 @@
>         print '\t%7.3f' % rtt_per_op,
>         print '\t%7.3f' % exe_per_op
>
> +    def ops(self, sample_time):
> +        sends = float(self.__rpc_data['rpcsends'])
> +        if sample_time == 0:
> +            sample_time = float(self.__nfs_data['age'])
> +        return (sends / sample_time)
> +
> +
>     def display_iostats(self, sample_time, which):
>         """Display NFS and RPC stats in an iostat-like way
>         """
> @@ -421,6 +428,11 @@
>     print ' If one or more <mount point> names are specified,  
> statistics for only these'
>     print ' mount points will be displayed.  Otherwise, all NFS  
> mount points on the'
>     print ' client are listed.'
> +    print
> +    print ' You can also specify "--top" to sort the NFS mount  
> points by ops/second,'
> +    print ' and specify a number of mount points to return with - 
> <num>, e.g. -1.'
> +    print ' For example, use of "--top -1" will iterate only  
> showing you the stats'
> +    print ' for the mount point with the largest ops/second.'
>
> def parse_stats_file(filename):
>     """pop the contents of a mountstats file into a dictionary,
> @@ -446,26 +458,82 @@
>
>     return ms_dict
>
> -def print_iostat_summary(old, new, devices, time, ac):
> -    for device in devices:
> +def print_iostat_summary(old, new, devices, time, ac, sortbyops,  
> entrycount):
> +    diff_stats = { }
> +    count = 1
> +
> +    if old:
> +        # Trim device list to only include intersection of old a  
> new data,
> +        # this addresses changes due to automount
> +        devicelist = filter(lambda x:x in devices,old)
> +    else:
> +        devicelist = devices
> +
> +    for device in devicelist:
> +        count += 1
>         stats = DeviceData()
>         stats.parse_stats(new[device])
>         if not old:
>             stats.display_iostats(time, ac)
> +            if (count>entrycount):
> +                return
>         else:
>             old_stats = DeviceData()
>             old_stats.parse_stats(old[device])
> -            diff_stats = stats.compare_iostats(old_stats)
> -            diff_stats.display_iostats(time, ac)
> +            diff_stats[device] = stats.compare_iostats(old_stats)
> +            if not sortbyops:
> +                diff_stats[device].display_iostats(time, ac)
> +                if (count>entrycount):
> +                    return
> +
> +    if old and sortbyops:
> +        # We had old data and could formulate a comparison
> +        # Now print comparison ordered by mountpoint ops per second
> +        count = 1
> +
> +        devices.sort(key=lambda x: diff_stats[x].ops(time),  
> reverse=True)
> +
> +        for device in devices:
> +            count += 1
> +            diff_stats[device].display_iostats(time, ac)
> +            if (count>entrycount):
> +                return
> +
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
>
> def iostat_command(name):
>     """iostat-like command for NFS mount points
>     """
>     mountstats = parse_stats_file('/proc/self/mountstats')
>     devices = []
> +    origdevices = []
>     which = 0
>     interval_seen = False
>     count_seen = False
> +    sortbyops = False
> +    entrycount = sys.maxint
> +
>
>     for arg in sys.argv:
>         if arg in ['-h', '--help', 'help', 'usage']:
> @@ -476,6 +544,19 @@
>             print '%s version %s' % (name, Iostats_version)
>             return
>
> +        if arg in ['-t', '--top', 'top']:
> +            sortbyops = True
> +            # top-like display infers a loop, default to 1 second
> +            if not interval_seen:
> +                interval = 1
> +                interval_seen = True
> +            continue
> +
> +        stop_re = re.compile('-[0-9]+')
> +        if stop_re.match(arg):
> +            entrycount = int(arg.lstrip('-'))
> +            continue
> +
>         if arg in ['-a', '--attr']:
>             which = 1
>             continue
> @@ -492,7 +573,7 @@
>             continue
>
>         if arg in mountstats:
> -            devices += [arg]
> +            origdevices += [arg]
>         elif not interval_seen:
>             interval = int(arg)
>             if interval > 0:
> @@ -509,47 +590,42 @@
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
>
>     if not interval_seen:
> -        print_iostat_summary(old_mountstats, mountstats, devices,  
> sample_time, which)
> +        print_iostat_summary(old_mountstats, mountstats, devices,  
> sample_time, which, sortbyops, entrycount)
>         return
>
> +
> +    # Need to check for automount here and then use that flag below  
> instead of always recalculating
> +
>     if count_seen:
>         while count != 0:
> -            print_iostat_summary(old_mountstats, mountstats,  
> devices, sample_time, which)
> +            print_iostat_summary(old_mountstats, mountstats,  
> devices, sample_time, which, sortbyops, entrycount)
>             old_mountstats = mountstats
>             time.sleep(interval)
>             sample_time = interval
>             mountstats = parse_stats_file('/proc/self/mountstats')
> +
> +            # automount mountpoints add and drop, if automount is  
> involved we need to recheck the
> +            # devices list when reiterating the check
> +            devices = list_nfs_mounts(origdevices,mountstats)
> +
>             count -= 1
>     else:
>         while True:
> -            print_iostat_summary(old_mountstats, mountstats,  
> devices, sample_time, which)
> +            print_iostat_summary(old_mountstats, mountstats,  
> devices, sample_time, which, sortbyops, entrycount)
>             old_mountstats = mountstats
>             time.sleep(interval)
>             sample_time = interval
>             mountstats = parse_stats_file('/proc/self/mountstats')
>
> +            # automount mountpoints add and drop, if automount is  
> involved we need to recheck the
> +            # devices list when reiterating the check
> +            devices = list_nfs_mounts(origdevices,mountstats)
> #
> # Main
> #
> ------------------------------------------------------------------------------
> Let Crystal Reports handle the reporting - Free Crystal Reports 2008  
> 30-Day
> trial. Simplify your report design, integration and deployment - and  
> focus on
> what you do best, core application coding. Discover what's new with
> Crystal Reports now.  http://p.sf.net/sfu/bobj-july_______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



