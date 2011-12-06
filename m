Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60772 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750868Ab1LFJEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 04:04:53 -0500
Date: Tue, 6 Dec 2011 10:04:50 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111206090450.GB3570@janus>
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
> list of pending rpc_tasks as well as information on where they are
> sleeping.
> Can you please try this on one of the hanging clients and post the
> resulting dump?

Here's another one:
-pid- flgs status -client- --rqstp- -timeout ---ops--
28050 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:none
28074 0080    -11 c2d3c460 c8e82000        0 c191c4ac nfsv3 LOOKUP a:call_status q:xprt_sending
28078 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
28080 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
28085 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28086 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28087 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28089 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28090 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28091 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28092 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28093 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28094 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28095 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28096 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28097 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28098 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28099 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28100 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28106 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28107 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28108 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28109 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28111 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28112 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28113 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28114 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28115 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28116 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28117 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28118 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28119 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28120 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28121 0001    -11 c2d3c460   (null)        0 c182e34c nfsv3 READ a:call_reserveresult q:xprt_sending
28131 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28144 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28145 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
28169 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28170 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
28207 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28210 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28228 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28237 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28297 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
28306 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28311 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 LOOKUP a:call_reserveresult q:xprt_sending
28385 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
28401 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
28915 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
29279 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
29393 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
29469 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
37587 0080    -11 c2d3c460   (null)        0 c191c4ac nfsv3 FSSTAT a:call_reserveresult q:xprt_sending


-- 
Frank
