Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54066 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191Ab0DPPuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 11:50:18 -0400
Message-ID: <4BC88722.3040604@oracle.com>
Date: Fri, 16 Apr 2010 11:49:54 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Why is remount necessary after rebooting server?
References: <4BC7FFCF.8030003@msgid.tls.msk.ru>
In-Reply-To: <4BC7FFCF.8030003@msgid.tls.msk.ru>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/16/2010 02:12 AM, Michael Tokarev wrote:
> Hello.
>
> It has been a while since I've seen.. issues with nfs for the
> last time. Now I hit a limitation of number of groups in nfs3,
> and had to switch to nfs4.  And immediately hit another problem,
> which makes the whole thing almost unusable for us.
>
> The problem is that each time the nfs server is rebooted, I have
> to - it boils down to - forcibly REBOOT each client which has
> some mounts from the said server. Because, well, remount - in
> theory - should be sufficient, but I can't perform remount because
> the filesystem(s) in question are busy.
>
> Here's a typical situation (after reboot):
>
> # ls /net/gnome/home
> ls: cannot access /net/gnome/home: Stale NFS file handle
>
> # mount | tail -n2
> gnome:/ on /net/gnome type nfs4
> (rw,nosuid,nodev,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.88.2,addr=192.168.88.4)
>
> gnome:/home on /net/gnome/home type nfs4
> (rw,nosuid,nodev,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.88.2,addr=192.168.88.4)
>
>
> # umount /net/gnome/home
> umount.nfs4: /net/gnome/home: device is busy
> umount.nfs4: /net/gnome/home: device is busy
>
> # umount -f /net/gnome/home
> umount2: Device or resource busy
> umount.nfs4: /net/gnome/home: device is busy
> umount2: Device or resource busy
> umount.nfs4: /net/gnome/home: device is busy
>
> # umount -f /net/gnome
> umount2: Device or resource busy
> umount.nfs4: /net/gnome: device is busy
> umount2: Device or resource busy
> umount.nfs4: /net/gnome: device is busy

> At this point, there are two ways:
>
> 1. try to find and kill all processes which are using
> the mountpoint. But in almost all cases it is not
> possible since there is at least one process which is
> in D state and unkillable, so we proceed to variant 2:
>
> 2. echo b > /proc/sysrq-trigger
> or something of this sort, since it will not be able
> umount / anyway.
>
> Note that even if 1. succeed, the system is unusable anyway,
> since it is here to service users. So it is simpler and
> faster to proceed to 2. stright away.
>
> What can be done to stop the "Stale NFS handle" situation
> from happening -- except of stopping rebooting the server?
> At least with nfs3 it has been almost solved (almost, because
> from time to time it still happens even with nfs3, leading
> to the same issue).

First, what is the kernel version on your server and clients?

ESTALE after a server reboot usually means that the file handle of the 
exported root has changed.  Can you tell us what physical file system 
type is being exported?

Since you are using automounter and /net, it could also mean that your 
clients are mounting an export, and after the server reboot, that export 
no longer exists.  So, one way you could fix this is by using static mounts.

Capturing a network trace on one of the clients across a server reboot 
could tell you how the server exports are changing across the reboot to 
cause the client heartburn.

-- 
chuck[dot]lever[at]oracle[dot]com
