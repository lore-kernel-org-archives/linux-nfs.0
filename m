From: =?iso-8859-1?Q?Peter_=C5strand?= <peter@cendio.se>
Subject: Re: broken umount -f
Date: Mon, 13 Jan 2003 10:44:33 +0100 (CET)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0301131028180.9395-100000@maggie.lkpg.cendio.se>
References: <15905.56794.440587.792199@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15905.56794.440587.792199@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

>>For as long as I remember, umount -f has been broken. I got a reminder
>>of this fact today when we took an older NFS server out of use. I had to
>>reboot almost all machines that had mounts from this server. Not nice.

...

> AFAICS It works for me.
> 
> Are you using the 'intr' mount option,

Yes, as often I can. But IMHO, it should be possible to unmount an
unreachable NFS fs even if it wasn't mounted with "intr". Otherwise we
have a quite silly "sysadmin trap".

>and are you remembering to kill
> those processes that are actually using the mount point first?

One some machines, I killed more or less everything. It didn't help. One
some other machines, I couldn't kill so blindly. Remember, both "lsof" and
"fuser" hangs.

Also, as far as I understand, Solaris 8 does not require that you kill all
processes before unmounting, if you use the "-f" flag (processes will get
EIO). Would it be possible to implement this feature in Linux? That would
be really nice.

Regards, Peter


>>For as long as I remember, umount -f has been broken. I got a reminder
>>of this fact today when we took an older NFS server out of use. I had to
>>reboot almost all machines that had mounts from this server. Not nice.
>>
>>Anyone knows why -f does not work? When I try, I get:
>>
>># umount -f /import/applix Cannot MOUNTPROG RPC: RPC: Port mapper
>>failure - RPC: Unable to receive umount2: Device or resource busy
>>umount: /import/applix: device is busy
>>
>>lsof and fuser hangs, as do "df" and "du". Really frustrating. It's not
>>even possible to cleanly reboot the system, since RedHats shutdown
>>scripts wants to unmount NFS fs's.
>>
>>I'm not exactly sure I understand what -f is supposed to do. Is it
>>correct that it is supposed to unmount without contacting the NFS
>>server? I assume that I still have to make sure no processes are using
>>the FS? Would it be possible to add a "-9" flag (or something like that)
>>that kills off all processes that uses the NFS fs automatically?
>>
>>(I'm using all kinds of RedHat Linux versions, from 5.0 up to 7.3. From
>>what I can tell, this problems exists in all versions.)
>>
