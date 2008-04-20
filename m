From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: lock stuck after interrupt
Date: Sun, 20 Apr 2008 14:45:15 -0400
Message-ID: <20080420184515.GA27536@fieldses.org>
References: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, eshel@almaden.ibm.com, neilb@suse.de,
	akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47782 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbYDTSpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Apr 2008 14:45:30 -0400
In-Reply-To: <E1JmY9Y-0004e4-7R-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2008 at 07:44:08PM +0200, Miklos Szeredi wrote:
> 1) on server lock file X
> 2) on client lock file X
>      blocks
> 3) on client send interrupt to process doing locking
>      locking syscall restarted, continues blocking
> 4) on server release lock on file X
>      on client lock is acquired
> 5) on client release lock on file X
> 6) on client lock file X
>      blocks
> 
> Everything up to the last step is fine, but something goes wrong
> during the final unlock.  Stopping the nfs-server removes the stray
> lock.
> 
> Here's a trace on the server:
> 
> lockd: request from 192.168.1.1, port=862
> lockd: LOCK          called
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nsm_monitor(tucsk)
> lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: creating file for (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: found file 0ad074c0 (count 0)
> lockd: nlmsvc_lock(ubda/96317, ty=1, pi=1, 0-99, bl=1)
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nlmsvc_lookup_block f=0ad074c0 pd=1 0-99 ty=1
> lockd: get host tucsk
> lockd: created block 0aeabf80...
> lockd: vfs_lock_file returned 1

Why is vfs_lock_file returning 1?  It should be 0 or -ERRNO.

--b.

> lockd: nlmsvc_insert_block(0aeabf80, -1)
> lockd: release host tucsk
> lockd: nlmsvc_lock returned 50331648
> lockd: LOCK         status 3
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 2)
> lockd: request from 192.168.1.1, port=862
> lockd: CANCEL        called
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: found file 0ad074c0 (count 1)
> lockd: nlmsvc_cancel(ubda/96317, pi=1, 0-99)
> lockd: nlmsvc_lookup_block f=0ad074c0 pd=1 0-99 ty=1
> lockd: check f=0ad074c0 pd=1 0-99 ty=1 cookie=36120000
> lockd: unlinking block 0aeabf80...
> lockd: freeing block 0aeabf80...
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 2)
> lockd: CANCEL        status 0
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 1)
> lockd: closing file ubda/96317
> lockd: request from 192.168.1.1, port=862
> lockd: LOCK          called
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nsm_monitor(tucsk)
> lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: creating file for (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: found file 0ad074c0 (count 0)
> lockd: nlmsvc_lock(ubda/96317, ty=1, pi=2, 0-99, bl=1)
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nlmsvc_lookup_block f=0ad074c0 pd=2 0-99 ty=1
> lockd: get host tucsk
> lockd: created block 0aeab240...
> lockd: vfs_lock_file returned 0
> lockd: freeing block 0aeab240...
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 2)
> lockd: release host tucsk
> lockd: nlmsvc_lock returned 0
> lockd: LOCK         status 0
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 1)
> lockd: request from 192.168.1.1, port=862
> lockd: UNLOCK        called
> lockd: nlm_lookup_host(192.168.1.2->192.168.1.1, p=6, v=4, my role=server, name=tucsk)
> lockd: get host tucsk
> lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 7f54ef79 00017801 d06c5915 00000000)
> lockd: found file 0ad074c0 (count 0)
> lockd: nlmsvc_unlock(ubda/96317, pi=3, 0-9223372036854775807)
> lockd: nlmsvc_cancel(ubda/96317, pi=3, 0-9223372036854775807)
> lockd: nlmsvc_lookup_block f=0ad074c0 pd=3 0-9223372036854775807 ty=2
> lockd: UNLOCK        status 0
> lockd: release host tucsk
> lockd: nlm_release_file(0ad074c0, ct = 1)
> 
> 
> Everything looks normal, yet...
> 
> This is 100% reproducable for me (ext3 exported over nfs, server and
> client: 2.6-git).
> 
> Miklos
