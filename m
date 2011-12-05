Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756408Ab1LEXjh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 18:39:37 -0500
Message-ID: <1323128376.7237.7.camel@lade.trondhjem.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 05 Dec 2011 18:39:36 -0500
In-Reply-To: <20111205165021.GA24165@janus>
References: <20111205165021.GA24165@janus>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-05 at 17:50 +0100, Frank van Maarseveen wrote: 
> After upgrading 50+ NFSv3 (over UDP) client machines from 3.0.x to
> 3.1.4 I occasionally noticed a machine with lots of processes hanging
> in __rpc_execute() for a specific mount point with no progress at all.
> Stack:
> 
> 	[<c17fe7e0>] schedule+0x30/0x50
> 	[<c177e259>] rpc_wait_bit_killable+0x19/0x30
> 	[<c17feeb5>] __wait_on_bit+0x45/0x70
> 	[<c177e240>] ? rpc_release_task+0x110/0x110
> 	[<c17fef3d>] out_of_line_wait_on_bit+0x5d/0x70
> 	[<c177e240>] ? rpc_release_task+0x110/0x110
> 	[<c108aed0>] ? autoremove_wake_function+0x40/0x40
> 	[<c177e89b>] __rpc_execute+0xdb/0x1a0
> 	...
> 
> Every reference to the specific mount point on the client machine hangs
> and the server does not receive any related network traffic. The server
> works fine for other identical client machines with the same export mounted.
> Other mounts on the (now) broken client still work. Killing the hanging
> client processes repairs the situation.
> 
> This has happened a couple of times on client machines with heavy (NFS)
> load. The mount-point has originally been mounted by the automounter.

An command of 'echo 0 > /proc/sys/sunrpc/rpc_debug', should display a
list of pending rpc_tasks as well as information on where they are
sleeping.
Can you please try this on one of the hanging clients and post the
resulting dump?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

