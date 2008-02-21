From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Thu, 21 Feb 2008 12:18:18 +0100
Message-ID: <47BD5DFA.8080200@foo-lounge.de>
References: <47BCA119.2030404@foo-lounge.de> <18364.64328.189954.417159@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:39095 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086AbYBULSV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2008 06:18:21 -0500
In-Reply-To: <18364.64328.189954.417159-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

first of all, thanks for replying.


Neil Brown wrote:
> On Wednesday February 20, mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org wrote:
>> Although there should be nothing accessing the disk except my custom
>> backup cron job initiating at 5am daily, something was constantly
>> bringing it back into active state after a rough 20-25 minutes. With the
>> help of blktrace, I monitored every single I/O access to the disk and
>> found a single process only that would cause the wake-up:
>>
>>
>> So for some reason, rpc.mountd issues this disk request in regular
>> intervals although nothing on the disk is being NFS-exported according
>> to /etc/exports.
> 
> This is doubtlessly something related to libblkid.
> 
> We use libblkid to get a unique UID for each filesystem and use that
> as an identified in the filehandle.
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
> 
> Not an ideal solution...

What would be the downside of that solution? I suppose NFS would keep on
working even if I disabled that switch, but you gave the impression
there was some (major) drawback.


Cheers,

--Timo
