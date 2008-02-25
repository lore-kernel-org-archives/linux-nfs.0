From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Mon, 25 Feb 2008 15:24:49 +0100
Message-ID: <47C2CFB1.4000004@foo-lounge.de>
References: <47BCA119.2030404@foo-lounge.de> <18364.64328.189954.417159@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:45338 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbYBYOZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2008 09:25:19 -0500
In-Reply-To: <18364.64328.189954.417159-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Wednesday February 20, mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org wrote:
>> Although there should be nothing accessing the disk except my custom
>> backup cron job initiating at 5am daily, something was constantly
>> bringing it back into active state after a rough 20-25 minutes. With the
>> help of blktrace, I monitored every single I/O access to the disk and
>> found a single process only that would cause the wake-up:
>>
>>
>> $ sudo blkparse -i hda.blktrace.0
>> Input file hda.blktrace.0 added
>> [...]
>>   3,0    0        6    88.950000000  6806  Q   R 447 + 8 [rpc.mountd]
>> [...]
>>
>>
>> So for some reason, rpc.mountd issues this disk request in regular
>> intervals although nothing on the disk is being NFS-exported according
>> to /etc/exports.
> 
> This is doubtlessly something related to libblkid.
> 
> We only ever ask it for the UID of specific devices that have been
> exported.  However it is quite possible that it touches other devices
> as well...
> 
> I'm using libblkid in a way that it wasn't originally designed to be
> used.  It was (as far as I can tell) designed to find a device given a
> UUID or similar.  In that case you would expect it to touch every
> device.
> 
> You could always build your own nfs-utils and configure with
> --without-uuid.

I did so and re-compiled the nfs-utils package, resulting in new
packages of nfs-common and nfs-kernel-server under Ubuntu 7.10.

However, another re-run of blktrace yielded that the problem did not go
away. There are still lots of disk accesses from mountd, and the strace
output continuously contains open calls to the unmounted backup filesystem.


Is there anything else I can do in attempt to resolve this issue? I
suppose pasting the complete output of strace might help, but I wouldn't
do so without explicit confirmation of yours as the log-file is 3.2 MB
large.


--Timo
