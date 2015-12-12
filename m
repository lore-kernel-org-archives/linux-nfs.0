Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from galahad.ideasonboard.com ([185.26.127.97]:37955 "EHLO
	galahad.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbbLLT7w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Dec 2015 14:59:52 -0500
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: NFS issue on v4.4-rc3
Date: Sat, 12 Dec 2015 22:00:03 +0200
Message-ID: <1680770.7KV5O8ZiSM@avalon>
In-Reply-To: <21970607.rdfIyEsdfn@avalon>
References: <21970607.rdfIyEsdfn@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping ?

On Saturday 05 December 2015 00:53:24 Laurent Pinchart wrote:
> Hello,
> 
> I ran into the following warning when running v4.4-rc3 on a TI OMAP4
> (pandaboard) using nfsroot.
> 
> [ 8063.208526] ------------[ cut here ]------------
> [ 8063.213653] WARNING: CPU: 1 PID: 81 at net/ipv4/af_inet.c:155
> inet_sock_destruct+0x188/0x1dc()
> [ 8063.213653] Modules linked in: vivid cfbfillrect cfbimgblt font
> videobuf2_dma_contig videobuf2_memops cfbcopyarea videobuf2_v4l2
> videobuf2_core fb omapdrm drm_kms_helper drm snd_soc_omap_abe_twl6040 e
> [ 8063.253143] CPU: 1 PID: 81 Comm: kworker/1:1H Not tainted
> 4.4.0-rc3-00249- g8555fa61a7ca-dirty #347
> [ 8063.269317] Hardware name: Generic OMAP4 (Flattened Device Tree)
> [ 8063.275634] Workqueue: rpciod xprt_autoclose
> [ 8063.275634] [<c0016f4c>] (unwind_backtrace) from [<c0013238>]
> (show_stack+0x10/0x14)
> [ 8063.288391] [<c0013238>] (show_stack) from [<c0341e68>]
> (dump_stack+0x80/0x9c)
> [ 8063.296020] [<c0341e68>] (dump_stack) from [<c003c458>]
> (warn_slowpath_common+0x7c/0xb8)
> [ 8063.296020] [<c003c458>] (warn_slowpath_common) from [<c003c4b0>]
> (warn_slowpath_null+0x1c/0x24)
> [ 8063.313812] [<c003c4b0>] (warn_slowpath_null) from [<c05f4c18>]
> (inet_sock_destruct+0x188/0x1dc)
> [ 8063.323059] [<c05f4c18>] (inet_sock_destruct) from [<c05679f8>]
> (sk_destruct+0x18/0x174)
> [ 8063.331604] [<c05679f8>] (sk_destruct) from [<c05f4974>]
> (inet_release+0x44/0x70)
> [ 8063.339508] [<c05f4974>] (inet_release) from [<c056167c>]
> (sock_release+0x20/0xb8)
> [ 8063.347503] [<c056167c>] (sock_release) from [<c063ebac>]
> (xs_close+0xc/0x20)
> [ 8063.355041] [<c063ebac>] (xs_close) from [<c063c0d4>]
> (xprt_autoclose+0x30/0x64)
> [ 8063.362854] [<c063c0d4>] (xprt_autoclose) from [<c00559c4>]
> (process_one_work+0x1b4/0x4ac)
> [ 8063.371551] [<c00559c4>] (process_one_work) from [<c0055e44>]
> (worker_thread+0x154/0x470)
> [ 8063.380187] [<c0055e44>] (worker_thread) from [<c005bb88>]
> (kthread+0xd0/0xec)
> [ 8063.387817] [<c005bb88>] (kthread) from [<c000f870>]
> (ret_from_fork+0x14/0x24)
> [ 8063.395446] ---[ end trace 6ced06624a647c32 ]---
> 
> The problem occurred twice only over several hours and wasn't linked to any
> particular operation.
> 
> Before the first occurrence I also got errors printed right after boot on
> both the client and the server side kernel logs. The server side read as
> follows.
> 
> [72948.929645] oversized read request from 192.168.1.254, port=938
> (1426618135 bytes)
> [72954.726793] oversized read request from 192.168.1.254, port=938 (67248960
> bytes)
> 
> I'm afraid the client messages have been lost in my scroll buffer, but they
> were related to the to oversized requests as well.
> 
> I've been running the same setup on v4.3 without any issue for quite a long
> time.

-- 
Regards,

Laurent Pinchart

