Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41487 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856Ab1FAOkK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 10:40:10 -0400
Subject: Re: [PATCH] NFS: fix umount of pnfs filesystems
Content-Type: text/plain; charset=us-ascii
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <4DE5DE71.2090601@panasas.com>
Date: Wed, 1 Jun 2011 10:39:54 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <9D92A547-5DA1-427E-A0A9-127AD83C3A45@netapp.com>
References: <1306891804-8070-1-git-send-email-dros@netapp.com> <4DE5DE71.2090601@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 1, 2011, at 2:38 AM, Boaz Harrosh wrote:

> On 06/01/2011 04:30 AM, Weston Andros Adamson wrote:
>> Unmounting a pnfs filesystem hangs using filelayout and possibly others.
>> This fixes the use of the rcu protected node by making use of a new 'tmpnode'
>> for the temporary purge list. Also, the spinlock shouldn't be held when calling
>> synchronize_rcu().
>> 
> 
> I like the new code, but I have two questions:
> 
> * Why didn't I see this hang? (Maybe because I run uni-processor)
> * How do you have this problem. Usually with the regular usage of device-cache
>  all deviceids get released when layouts go away. So by the time client_purge comes
>  in there are no more devices in the cache. At objects-ld I take an extra ref at
>  first add_dev which is then get released in client_purge?
> 
> Thanks
> Boaz

Yeah, I saw the hangs on a vmware guest with two processors.

I believe it looked like this (I can revert and test again if you want the full traces):

1) Umount process calls client_purge, calls synchronize_rcu while holding lock
2) another process notices that it should call client_purge, spins trying acquire lock

With the file layout, there are definitely devices in the cache when umount is called.
Note, I could only reproduce this by: mounting remote fs, write one byte to a file on remote fs, umount.
If I get rid of the "write one byte" step, there is no hang.

-dros