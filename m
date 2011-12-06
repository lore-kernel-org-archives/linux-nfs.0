Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60769 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932987Ab1LFILR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 03:11:17 -0500
Date: Tue, 6 Dec 2011 09:11:15 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111206081115.GA3570@janus>
References: <20111205165021.GA24165@janus>
 <1323128376.7237.7.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323128376.7237.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 05, 2011 at 06:39:36PM -0500, Trond Myklebust wrote:
> On Mon, 2011-12-05 at 17:50 +0100, Frank van Maarseveen wrote: 
> > After upgrading 50+ NFSv3 (over UDP) client machines from 3.0.x to
> > 3.1.4 I occasionally noticed a machine with lots of processes hanging
> > in __rpc_execute() for a specific mount point with no progress at all.
> > Stack:
> > 
> > 	[<c17fe7e0>] schedule+0x30/0x50
> > 	[<c177e259>] rpc_wait_bit_killable+0x19/0x30
> > 	[<c17feeb5>] __wait_on_bit+0x45/0x70
> > 	[<c177e240>] ? rpc_release_task+0x110/0x110
> > 	[<c17fef3d>] out_of_line_wait_on_bit+0x5d/0x70
> > 	[<c177e240>] ? rpc_release_task+0x110/0x110
> > 	[<c108aed0>] ? autoremove_wake_function+0x40/0x40
> > 	[<c177e89b>] __rpc_execute+0xdb/0x1a0
> > 	...
> > 
> > Every reference to the specific mount point on the client machine hangs
> > and the server does not receive any related network traffic. The server
> > works fine for other identical client machines with the same export mounted.
> > Other mounts on the (now) broken client still work. Killing the hanging
> > client processes repairs the situation.
> > 
> > This has happened a couple of times on client machines with heavy (NFS)
> > load. The mount-point has originally been mounted by the automounter.
> 
> An command of 'echo 0 > /proc/sys/sunrpc/rpc_debug', should display a

36477 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:none
36479 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36484 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36485 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36486 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36487 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36488 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36489 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36490 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36491 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36492 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36493 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36494 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36495 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36496 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
36497 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36498 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36499 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36500 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36501 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36502 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36503 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
36504 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36505 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36506 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36507 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36508 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36509 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36510 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36511 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36512 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36513 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36514 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36515 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36516 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36517 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36518 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36519 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36523 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36560 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36561 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36562 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36563 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36564 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36565 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36566 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36576 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
36577 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36578 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36579 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36580 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36581 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36582 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36583 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending
36592 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
36618 0001    -11 ffff88008dc9db60   (null)        0 ffffffff8193ba60 nfsv3 WRITE a:call_reserveresult q:xprt_sending
21609 0080    -11 ffff88008dc9db60   (null)        0 ffffffff81a68860 nfsv3 ACCESS a:call_reserveresult q:xprt_sending

-- 
Frank
