Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:40521 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932281Ab0KKCfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 21:35:22 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PGN0S-0004Hh-SP
	for linux-nfs@vger.kernel.org; Wed, 10 Nov 2010 18:35:20 -0800
Date: Wed, 10 Nov 2010 18:35:20 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101111023520.GH16939@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Still seeing all sorts of boxes fall over with 2.6.35 and 2.6.36 NFS.
Unfortunately, it doesn't happen all the time...only certain load
patterns seem to start it off.  Once it starts, I can't find a way to
make it recover without rebooting.

In this case, tcpdump and rpc/nfs debug logs show a repeating command,
but only 3-4 commands are being sent per second, even though all slots
are in use, there is a backlog, 300 processes in rpc_wait_bit_killable,
and the debug logs show that responses are coming back immediately. 
Weird congestion/backoff issue?

Over a few seconds, the only numbers changing from "nfsstat" are "calls",
"authrefresh", and "getattr".  Debug level 1 for nfs and rpc show this
repeating:

 NFS: permission(0:4c/5284877), mask=0x1, res=0
 RPC:  5778 reserved req ffff88012ae042d0 xid 64030e74
 RPC:  5778 xprt_prepare_transmit
 RPC:  5778 xprt_transmit(96)
 RPC:  5778 xmit complete
 RPC:  5778 xid 64030e74 complete (112 bytes received)
 RPC:  5778 release request ffff88012ae042d0
 NFS: nfs_update_inode(0:4c/3247737045 ct=1 info=0x7e7f)
 NFS: permission(0:4c/3247737045), mask=0x24, res=0
 NFS: dentry_delete(tmp/t.sh, 8)
 NFS: dentry_delete(tmp/9040-16697.done, 8)
 NFS: dentry_delete(tmp/9040-29371.done, 8)

The only thing that changes between repeats are the pid and xid.

Debug level 255 for nfs and rpc:

NFS call  getattr
RPC:       new task initialized, procpid 15460
RPC:       allocated task ffff8800c09f7e00
RPC:  5321 __rpc_execute flags=0x80
RPC:  5321 call_start nfs3 proc GETATTR (sync)
RPC:  5321 call_reserve (status 0)
RPC:  5321 reserved req ffff88012ae042d0 xid 9e010e74
RPC:  5321 call_reserveresult (status 0)
RPC:  5321 call_refresh (status 0)
RPC:  5321 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:  5321 refreshing UNIX cred ffff880011ec1300
RPC:  5321 call_refreshresult (status 0)
RPC:  5321 call_allocate (status 0)
RPC:  5321 allocated buffer of size 552 at ffff880129b1d000
RPC:  5321 call_bind (status 0)
RPC:  5321 call_connect xprt ffff88012a74d000 is connected
RPC:  5321 call_transmit (status 0)
RPC:  5321 xprt_prepare_transmit
RPC:  5321 rpc_xdr_encode (status 0)
RPC:  5321 marshaling UNIX cred ffff880011ec1300
RPC:  5321 using AUTH_UNIX cred ffff880011ec1300 to wrap rpc data
RPC:  5321 xprt_transmit(96)
RPC:       xs_tcp_send_request(96) = 96
RPC:  5321 xmit complete
RPC:  5321 sleep_on(queue "xprt_pending" time 4494861481)
RPC:       xs_tcp_data_ready...
RPC:       xs_tcp_data_recv started
RPC:       reading TCP record fragment of length 112
RPC:       reading XID (4 bytes)
RPC:       reading reply for XID 9e010e74
RPC:       reading CALL/REPLY flag (4 bytes)
RPC:       read reply XID 9e010e74
RPC:  5321 added to queue ffff88012a74d3f8 "xprt_pending"
RPC:  5321 setting alarm for 900 ms
RPC:       XID 9e010e74 read 104 bytes
RPC:       xprt = ffff88012a74d000, tcp_copied = 112, tcp_offset = 112, tcp_reclen = 112
RPC:  5321 xid 9e010e74 complete (112 bytes received)
RPC:  5321 __rpc_wake_up_task (now 4494861481)
RPC:  5321 disabling timer
RPC:  5321 removed from queue ffff88012a74d3f8 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_tcp_data_recv done
RPC:       wake_up_next(ffff88012a74d2e8 "xprt_resend")
RPC:       wake_up_next(ffff88012a74d1d8 "xprt_sending")
RPC:  5321 call_status (status 112)
RPC:  5321 call_decode (status 112)
RPC:  5321 validating UNIX cred ffff880011ec1300
RPC:  5321 using AUTH_UNIX cred ffff880011ec1300 to unwrap rpc data
RPC:  5321 call_decode result 0
RPC:  5321 return 0, status 0
RPC:  5321 release task
RPC:       freeing buffer of size 552 at ffff880129b1d000
RPC:  5321 release request ffff88012ae042d0
RPC:       wake_up_next(ffff88012a74d508 "xprt_backlog")
RPC:       rpc_release_client(ffff88012016e400)
RPC:  5321 freeing task
NFS reply getattr: 0
NFS: nfs_update_inode(0:4c/3247737045 ct=1 info=0x7e7f)
NFS: (0:4c/3247737045) revalidation complete
NFS: nfs_lookup_revalidate(HWD/tmp) is valid
RPC:       looking up Generic cred
NFS: permission(0:4c/3247737045), mask=0x24, res=0
NFS: open dir(HWD/tmp)
RPC:       looking up Generic cred
NFS: readdir(HWD/tmp) starting at cookie 0
NFS: readdir_search_pagecache() searching for offset 0
NFS: find_dirent_page: searching page 0 for target 0
NFS: found cookie 4 at index 0
NFS: find_dirent_page: returns 0
NFS: readdir_search_pagecache: returns 0
NFS: nfs_do_filldir() filling starting @ cookie 4
NFS: dentry_delete(tmp/t.sh, 8)
NFS: dentry_delete(tmp/9040-16697.done, 8)
NFS: dentry_delete(tmp/9040-29371.done, 8)
NFS: nfs_do_filldir() filling ended @ cookie 512; returning = 0
NFS: readdir(HWD/tmp) returns 0
NFS: readdir(HWD/tmp) starting at cookie 5
NFS: readdir_search_pagecache() searching for cookie 512
NFS: find_dirent_page: searching page 0 for target 512
NFS: find_dirent: examining cookie 4
NFS: find_dirent: examining cookie 6
NFS: find_dirent: examining cookie 11
NFS: find_dirent: examining cookie 18
NFS: find_dirent: examining cookie 512
NFS: find_dirent_page: returns -523
NFS: readdir_search_pagecache: returns -523
NFS: readdir(HWD/tmp) returns 0
RPC:       looking up Generic cred
NFS: permission(0:4c/5284877), mask=0x1, res=0
NFS: revalidating (0:4c/3247737045)

900ms matches the probably-silly nfs mount settings we're currently using:

rw,hard,intr,tcp,timeo=9,retrans=3,rsize=8192,wsize=8192

Full kernel log here: http://0x.ca/sim/ref/2.6.36_stuck_nfs/

Simon-
