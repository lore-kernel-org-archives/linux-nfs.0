From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: nfs: lock stuck after interrupt
Date: Sun, 20 Apr 2008 21:24:54 +0200
Message-ID: <E1Jnf9i-0001Lo-Tk@pomaz-ex.szeredi.hu>
References: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu> <20080420184515.GA27536@fieldses.org>
Cc: miklos@szeredi.hu, trond.myklebust@fys.uio.no,
	eshel@almaden.ibm.com, neilb@suse.de, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:54794 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbYDTTZ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Apr 2008 15:25:28 -0400
In-reply-to: <20080420184515.GA27536@fieldses.org> (bfields@fieldses.org)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > lockd: vfs_lock_file returned 1
> 
> Why is vfs_lock_file returning 1?  It should be 0 or -ERRNO.

Er sorry, that was the "return special value for async lock requests"
patch, which I was testing at the time.

It doesn't make a difference, but here's the log for nfs-2.6.git.  It
also contains a '/etc/init.d/nfs-kernel-server stop' at the end, which
eventually removes the stuck lock.

Miklos


[  180.770000] lockd: request from 192.168.1.3, port=928
[  180.770000] lockd: LOCK          called
[  180.770000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  180.770000] lockd: get host uml2
[  180.770000] lockd: nsm_monitor(uml2)
[  180.770000] lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  180.770000] lockd: creating file for (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  180.770000] lockd: found file 0ad722c0 (count 0)
[  180.770000] lockd: nlmsvc_lock(ubda/96317, ty=1, pi=1, 0-99, bl=1)
[  180.770000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  180.770000] lockd: get host uml2
[  180.770000] lockd: nlmsvc_lookup_block f=0ad722c0 pd=1 0-99 ty=1
[  180.770000] lockd: get host uml2
[  180.770000] lockd: created block 0ae26200...
[  180.770000] lockd: vfs_lock_file returned -11
[  180.770000] lockd: nlmsvc_insert_block(0ae26200, -1)
[  180.770000] lockd: release host uml2
[  180.770000] lockd: nlmsvc_lock returned 50331648
[  180.770000] lockd: LOCK         status 3
[  180.770000] lockd: release host uml2
[  180.770000] lockd: nlm_release_file(0ad722c0, ct = 2)
[  181.490000] lockd: request from 192.168.1.3, port=928
[  181.490000] lockd: CANCEL        called
[  181.490000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  181.490000] lockd: get host uml2
[  181.490000] lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  181.490000] lockd: found file 0ad722c0 (count 1)
[  181.490000] lockd: nlmsvc_cancel(ubda/96317, pi=1, 0-99)
[  181.490000] lockd: nlmsvc_lookup_block f=0ad722c0 pd=1 0-99 ty=1
[  181.490000] lockd: check f=0ad722c0 pd=1 0-99 ty=1 cookie=36120000
[  181.490000] lockd: unlinking block 0ae26200...
[  181.490000] lockd: freeing block 0ae26200...
[  181.490000] lockd: release host uml2
[  181.490000] lockd: nlm_release_file(0ad722c0, ct = 2)
[  181.490000] lockd: CANCEL        status 0
[  181.490000] lockd: release host uml2
[  181.490000] lockd: nlm_release_file(0ad722c0, ct = 1)
[  181.490000] lockd: closing file ubda/96317
[  181.490000] lockd: request from 192.168.1.3, port=928
[  181.490000] lockd: LOCK          called
[  181.490000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  181.490000] lockd: get host uml2
[  181.490000] lockd: nsm_monitor(uml2)
[  181.490000] lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  181.490000] lockd: creating file for (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  181.490000] lockd: found file 0ad722c0 (count 0)
[  181.490000] lockd: nlmsvc_lock(ubda/96317, ty=1, pi=2, 0-99, bl=1)
[  181.490000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  181.490000] lockd: get host uml2
[  181.490000] lockd: nlmsvc_lookup_block f=0ad722c0 pd=2 0-99 ty=1
[  181.490000] lockd: get host uml2
[  181.490000] lockd: created block 0ae26200...
[  181.490000] lockd: vfs_lock_file returned -11
[  181.490000] lockd: nlmsvc_insert_block(0ae26200, -1)
[  181.490000] lockd: release host uml2
[  181.490000] lockd: nlmsvc_lock returned 50331648
[  181.490000] lockd: LOCK         status 3
[  181.490000] lockd: release host uml2
[  181.490000] lockd: nlm_release_file(0ad722c0, ct = 2)
[  183.390000] lockd: VFS unblock notification for block 0ad6c0c4
[  183.390000] lockd: nlmsvc_insert_block(0ae26200, 0)
[  183.390000] nlmsvc_retry_blocked(0ae26200, when=-11661)
[  183.390000] lockd: grant blocked lock 0ae26200
[  183.390000] lockd: unlinking block 0ae26200...
[  183.390000] lockd: GRANTing blocked lock.
[  183.390000] lockd: nlmsvc_insert_block(0ae26200, -1)
[  183.390000] lockd: call procedure 10 on uml2 (async)
[  183.390000] lockd: nlm_bind_host(192.168.1.2->192.168.1.3)
[  183.390000] lockd: GRANT_MSG RPC callback
[  183.390000] lockd: nlmsvc_insert_block(0ae26200, 6000)
[  183.390000] lockd: request from 192.168.1.3, port=758
[  183.390000] lockd: GRANTED_RES   called
[  183.390000] grant_reply: looking for cookie 1237, s=0 
[  183.390000] nlmsvc_find_block(37120000): block=0ae26200
[  183.390000] lockd: unlinking block 0ae26200...
[  183.390000] lockd: freeing block 0ae26200...
[  183.390000] lockd: release host uml2
[  183.390000] lockd: nlm_release_file(0ad722c0, ct = 1)
[  185.100000] lockd: request from 192.168.1.3, port=928
[  185.100000] lockd: UNLOCK        called
[  185.100000] lockd: nlm_lookup_host(192.168.1.2->192.168.1.3, p=6, v=4, my role=server, name=uml2)
[  185.100000] lockd: get host uml2
[  185.100000] lockd: nlm_lookup_file (02000001 00006200 00000002 0001783d 93dc4121 00017801 d06c5915 00000000)
[  185.100000] lockd: found file 0ad722c0 (count 0)
[  185.100000] lockd: nlmsvc_unlock(ubda/96317, pi=3, 0-9223372036854775807)
[  185.100000] lockd: nlmsvc_cancel(ubda/96317, pi=3, 0-9223372036854775807)
[  185.100000] lockd: nlmsvc_lookup_block f=0ad722c0 pd=3 0-9223372036854775807 ty=2
[  185.100000] lockd: UNLOCK        status 0
[  185.100000] lockd: release host uml2
[  185.100000] lockd: nlm_release_file(0ad722c0, ct = 1)
[  192.280000] lockd: shutting down host module
[  192.280000] lockd: nuking all hosts...
[  192.280000] lockd: host garbage collection
[  192.280000] lockd: nlmsvc_mark_resources
[  192.280000] lockd: delete host uml2
[  192.280000] nfsd: last server has exited
[  192.280000] nfsd: unexporting all filesystems



