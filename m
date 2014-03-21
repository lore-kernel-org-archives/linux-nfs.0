Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:41183 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCUU4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2014 16:56:23 -0400
Message-ID: <532CA76B.8050300@windriver.com>
Date: Fri, 21 Mar 2014 14:56:11 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <neilb@suse.de>, <linux-nfs@vger.kernel.org>
Subject: Re: race-free exportfs and unmount?
References: <532C9E49.2030007@windriver.com> <20140321202040.GC26831@fieldses.org>
In-Reply-To: <20140321202040.GC26831@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2014 02:20 PM, J. Bruce Fields wrote:
> On Fri, Mar 21, 2014 at 02:17:13PM -0600, Chris Friesen wrote:
>>
>> Hi,
>>
>> There was a linux-nfs thread in July 2012 with the subject "Linux
>> NFS and cached properties".  It discussed the fact that you can't
>> reliably do
>>
>> exportfs -u 192.168.1.11:/mnt
>> umount /mnt
>>
>> since there could be rpc users still running when exportfs returns,
>> so the umount fails thinking the filesystem is busy.
>
> There could also be clients holding opens, locks, or delegations on the
> export.
>
>> I'm running into this on a production system.
>>
>> Was anything ever done to resolve this issue?
>> If not are there any workarounds?
>
> You can shut down the server completely, unmount, and restart.

Just to clarify, you mean shut down the NFS server processes?  As in, 
"/etc/init.d/nfsserver stop"?

Currently there is another filesystem that stays exported and doing the 
above would take it down too....but I might be able to make that work if 
it's the only way.

> What is it you need to do exactly?

We have two servers that act as primary/secondary for a drbd-replicated 
filesystem.  The primary mounts the drbd filesystem and exports it via nfs.

This is used for OpenStack, so there should be very little 
contention--each compute node generally only touches the files 
corresponding to the VMs that it is hosting.  I don't think they would 
be doing NFS locks, but I could be wrong.

On a controlled failover, we need to take down the NFS server IP 
address, unexport the filesystem, unmount the drbd device, and set drbd 
to secondary.

What we're seeing is that the unexport passes, but the unmount fails.  A 
few minutes later one of our guys manually ran "exportfs -f" and that 
seemed to unblock things.

Chris
