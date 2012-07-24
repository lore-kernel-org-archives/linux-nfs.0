Return-Path: linux-nfs-owner@vger.kernel.org
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:2488 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654Ab2GXR2G convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 13:28:06 -0400
From: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: RE: Linux NFS and cached properties
Date: Tue, 24 Jul 2012 17:28:02 +0000
Message-ID: <D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
 <20120724143748.GC8570@fieldses.org>
In-Reply-To: <20120724143748.GC8570@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Thanks for the clarification.

(I'm repeating a lot of my original mail because of the Cc: list.)

> J. Bruce Fields
> I think that's right, though I'm curious how you're managing to hit
> that case reliably every time.  Or is this an intermittent failure?
It's an intermittent failure, but with the procedure shown below it is
fairly easy to reproduce.    The actual problem we see in our product
is because of the way external storage media are handled in user-land.

        192.168.1.10# mount -t xfs /dev/sdcr/sda1 /mnt
        192.168.1.10# exportfs 192.168.1.11:/mnt

        192.168.1.11# mount 192.168.1.10:/mnt /mnt
        192.168.1.11# umount /mnt

        192.168.1.10# exportfs -u 192.168.1.11:/mnt
        192.168.1.10# umount /mnt
        umount: can't umount /media/recdisk: Device or resource busy

What I actually do is the mount/unmount on the client via ssh.  That
is a good way to trigger the problem.

We see that during the un-export the NFS caches are not flushed
properly which is why the final unmount fails.

In net/sunrpc/cache.c the cache times (last_refresh, expiry_time,
flush_time) are measured in seconds.  If I understand the code somewhat
then during an NFS un-export the is done by setting the flush_time to
the current time.  The cache_flush() is called.  If in that same second
last_refresh is set to the current time then the cached item is not
flushed.  This will subsequently cause un-mount to fail because there
is still a reference to the mount point.

> J. Bruce Fields
> I ran across that recently while reviewing the code to fix a related
> problem.  I'm not sure what the best fix would be.
>
> Previously raised here:
>
>       http://marc.info/?l=linux-nfs&m=133514319408283&w=2

The description in your mail does indeed looks the same as the problem
that we see.

>From reading the code in net/sunrpc/cache.c I get the impression that it is
not really possible to reliably flush the caches for an un-exportfs such
that after flushing they will not accept entries for the un-exported IP/mount
point combination.

With kind regards,
Hans Zuidam


________________________________
The information contained in this message may be confidential and legally protected under applicable law. The message is intended solely for the addressee(s). If you are not the intended recipient, you are hereby notified that any use, forwarding, dissemination, or reproduction of this message is strictly prohibited and may be unlawful. If you are not the intended recipient, please contact the sender by return e-mail and destroy all copies of the original message.

