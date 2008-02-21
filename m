From: Neil Brown <neilb@suse.de>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Thu, 21 Feb 2008 15:17:12 +1100
Message-ID: <18364.64328.189954.417159@notabene.brown>
References: <47BCA119.2030404@foo-lounge.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55835 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003AbYBUERH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 23:17:07 -0500
In-Reply-To: message from Timo Reimann on Wednesday February 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday February 20, mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org wrote:
> Hi all,
> 
> I have two disks in my server, one of them (hda) being used for backups
> solely. To reduce noise level and power consumption, I have been trying
> to keep it running in standby mode (as opposed to active) most of the time.
> 
> Although there should be nothing accessing the disk except my custom
> backup cron job initiating at 5am daily, something was constantly
> bringing it back into active state after a rough 20-25 minutes. With the
> help of blktrace, I monitored every single I/O access to the disk and
> found a single process only that would cause the wake-up:
> 
> 
> $ sudo blkparse -i hda.blktrace.0
> Input file hda.blktrace.0 added
> [...]
>   3,0    0        6    88.950000000  6806  Q   R 447 + 8 [rpc.mountd]
> [...]
> 
> 
> So for some reason, rpc.mountd issues this disk request in regular
> intervals although nothing on the disk is being NFS-exported according
> to /etc/exports.

This is doubtlessly something related to libblkid.

We use libblkid to get a unique UID for each filesystem and use that
as an identified in the filehandle.

We only ever ask it for the UID of specific devices that have been
exported.  However it is quite possible that it touches other devices
as well...

I'm using libblkid in a way that it wasn't originally designed to be
used.  It was (as far as I can tell) designed to find a device given a
UUID or similar.  In that case you would expect it to touch every
device.

I'm doing the reverse and it probably isn't doing things the ideal
way.

I guess someone should figure out how libblkid works and make it work
better for us......

You could always build your own nfs-utils and configure with
--without-uuid.

Not an ideal solution...

NeilBrown
