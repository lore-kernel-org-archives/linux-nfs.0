Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:60006 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbaCUW6T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2014 18:58:19 -0400
Message-ID: <532CC3FF.700@windriver.com>
Date: Fri, 21 Mar 2014 16:58:07 -0600
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


What is different with shutting down the server completely vs unexporting?

Does shutting down the server somehow wait for in-flight operations to 
complete whereas the unexport doesn't?  I'm assuming that it can't just 
cancel in-progress disk I/O and as long as that's happening then we 
won't be able to unmount the filesystem.

Thanks,
Chris

