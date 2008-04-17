From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: nfs: lock stuck after interrupt
Date: Thu, 17 Apr 2008 15:30:14 -0400
Message-ID: <e7ca40f70804171230l31aa6978x6ebfb41f9e4e7ba7@mail.gmail.com>
References: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, trond.myklebust@fys.uio.no,
	eshel@almaden.ibm.com, neilb@suse.de, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Miklos Szeredi" <miklos@szeredi.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757765AbYDQTac@vger.kernel.org>
In-Reply-To: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We brought up this specific issue a few weeks ago in this thread:

http://marc.info/?l=linux-nfs&m=120663578712912&w=2

While we had a fix that tested out properly (third reply in the
thread), I believe Trond fixed this recently in a more "correct"
method with this patch (and series):

http://marc.info/?l=linux-nfs&m=120726349027607&w=2

We haven't had the opportunity to check Tronds' patch yet though.

-Aaron


On Thu, Apr 17, 2008 at 1:44 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> 1) on server lock file X
>  2) on client lock file X
>      blocks
>  3) on client send interrupt to process doing locking
>      locking syscall restarted, continues blocking
>  4) on server release lock on file X
>      on client lock is acquired
>  5) on client release lock on file X
>  6) on client lock file X
>      blocks
>
>  Everything up to the last step is fine, but something goes wrong
>  during the final unlock.  Stopping the nfs-server removes the stray
>  lock.
>
>  Here's a trace on the server:
>
>  lockd: request from 192.168.1.1, port=862
>  lockd: LOCK          called
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nsm_monitor(tucsk)
>  lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: creating file for (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: found file 0ad074c0 (count 0)
>  lockd: nlmsvc_lock(ubda/96317, ty=1, pi=1, 0-99, bl=1)
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nlmsvc_lookup_block f=0ad074c0 pd=1 0-99 ty=1
>  lockd: get host tucsk
>  lockd: created block 0aeabf80...
>  lockd: vfs_lock_file returned 1
>  lockd: nlmsvc_insert_block(0aeabf80, -1)
>  lockd: release host tucsk
>  lockd: nlmsvc_lock returned 50331648
>  lockd: LOCK         status 3
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 2)
>  lockd: request from 192.168.1.1, port=862
>  lockd: CANCEL        called
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: found file 0ad074c0 (count 1)
>  lockd: nlmsvc_cancel(ubda/96317, pi=1, 0-99)
>  lockd: nlmsvc_lookup_block f=0ad074c0 pd=1 0-99 ty=1
>  lockd: check f=0ad074c0 pd=1 0-99 ty=1 cookie=36120000
>  lockd: unlinking block 0aeabf80...
>  lockd: freeing block 0aeabf80...
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 2)
>  lockd: CANCEL        status 0
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 1)
>  lockd: closing file ubda/96317
>  lockd: request from 192.168.1.1, port=862
>  lockd: LOCK          called
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nsm_monitor(tucsk)
>  lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: creating file for (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: found file 0ad074c0 (count 0)
>  lockd: nlmsvc_lock(ubda/96317, ty=1, pi=2, 0-99, bl=1)
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nlmsvc_lookup_block f=0ad074c0 pd=2 0-99 ty=1
>  lockd: get host tucsk
>  lockd: created block 0aeab240...
>  lockd: vfs_lock_file returned 0
>  lockd: freeing block 0aeab240...
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 2)
>  lockd: release host tucsk
>  lockd: nlmsvc_lock returned 0
>  lockd: LOCK         status 0
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 1)
>  lockd: request from 192.168.1.1, port=862
>  lockd: UNLOCK        called
>  lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
>  lockd: get host tucsk
>  lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
>  lockd: found file 0ad074c0 (count 0)
>  lockd: nlmsvc_unlock(ubda/96317, pi=3, 0-9223372036854775807)
>  lockd: nlmsvc_cancel(ubda/96317, pi=3, 0-9223372036854775807)
>  lockd: nlmsvc_lookup_block f=0ad074c0 pd=3 0-9223372036854775807 ty=2
>  lockd: UNLOCK        status 0
>  lockd: release host tucsk
>  lockd: nlm_release_file(0ad074c0, ct = 1)
>
>
>  Everything looks normal, yet...
>
>  This is 100% reproducable for me (ext3 exported over nfs, server and
>  client: 2.6-git).
>
>  Miklos
>  --
>  To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
