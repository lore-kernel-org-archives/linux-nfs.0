Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35796 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbcAFLEk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2016 06:04:40 -0500
Received: by mail-wm0-f46.google.com with SMTP id f206so55299997wmf.0
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jan 2016 03:04:39 -0800 (PST)
Received: from [192.168.5.20] (cust210-dsl91-135-10.idnet.net. [91.135.10.210])
        by smtp.googlemail.com with ESMTPSA id d2sm95575630wjy.16.2016.01.06.03.04.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Wed, 06 Jan 2016 03:04:38 -0800 (PST)
From: Antony Cleave <antony.cleave@clustervision.com>
Subject: Multiple HA-NFS services sharing a single /var/lib/nfs folder
To: linux-nfs@vger.kernel.org
Message-ID: <568CF4C4.1040607@clustervision.com>
Date: Wed, 6 Jan 2016 11:04:36 +0000
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

I have been using Pacemaker and Corrosync with DRBD and shared storage 
devices for years in active-passive operation with a single filesystem. 
With this I normally have a subdir on the replicated/shared filesystem 
which I point /var/lib/nfs to using a symlink so that when the passive 
node takes over the block device is mounted and when nfs starts it 
receives all of the current locks from the failed node and I dont see 
any stale filehandles.

like this:

HA1
mount -t ext3 /dev/drbd0 /mnt/store1

and /mnt/store1 would contain the fs like this:
/mnt/store1/<filesandfolders>
/mnt/store1/varlibnfs

so this symlink is valid
/var/lib/nfs/ -> /mnt/store1/varlibnfs

NFS then exports /mnt/store1 to clients

if HA1 fails then HA2 will power it off and then repeat the steps above

Now when I have multiple shared storage devices (like 2x directly 
attached SAS RAID arrays each hosting a different filesystem) I'd like 
to avoid having a dedicated passive NFS node doing nothing to have 
failover capability. I want to have an active:active setup with HA1 
exporting /mnt/store1, HA2 exporting /mnt/store2. If HA2 were to fail 
HA1 would then mount and export both and if HA1 was to fail then HA2 
would export both.

With this in mind I have tried a test setup with 2 DRBD block devices 
extending the above setup slightly so that HA2 mounts /mnt/store1 via 
the NFS export  from HA1 which includes the varlibnfs folder (HA1 
remains the same). It seems to work without issues but I'm not sure if 
this is going to cause problems in the long run as I don't know if 
sharing /var/lib/nfs between multiple NFS filesystems is storing up a 
potential data corruption problem just waiting for the right conditions 
to occur

New setup:

HA2
mount -t ext3 /dev/drbd1 /mnt/store2
mount -t nfs HA1:/mnt/store1 /mnt/store1 ****

and /mnt/store2 would contain just the fs like this:
/mnt/store2/<filesandfolders>

so this symlink is still valid as /mnt/store1 is mounted from HA1 via NFS
/var/lib/nfs/ -> /mnt/store1/varlibnfs

If HA1 fails then pacemaker on HA2 powers off HA1  and then mounts 
/mnt/store1 from /dev/drbd0 so that it all keeps operating (after a 
brief delay)

In summary I have 3 Questions

1) will this break at some point?
2) If so, How do I do this properly?
3) Even if this is perfectly valid is there a better way to do this I 
should be using that will work in CentOS 6 and/or 7.

Thanks

Antony
