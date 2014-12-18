Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45042 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227AbaLRQcz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 11:32:55 -0500
Date: Thu, 18 Dec 2014 11:32:54 -0500
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: 3.18.1: broken directory with one file too many
Message-ID: <20141218163254.GF18179@fieldses.org>
References: <pan.2014.12.16.22.19.18@googlemail.com>
 <20141217212159.GA11517@fieldses.org>
 <5492C710.20104@googlemail.com>
 <20141218144856.GA18179@fieldses.org>
 <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
 <20141218151914.GB18179@fieldses.org>
 <pan.2014.12.18.15.42.53@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <pan.2014.12.18.15.42.53@googlemail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 18, 2014 at 03:42:53PM +0000, Holger Hoffstätte wrote:
> On Thu, 18 Dec 2014 10:19:14 -0500, J. Bruce Fields wrote:
> 
> > On Thu, Dec 18, 2014 at 09:58:06AM -0500, Benjamin Coddington wrote:
> >> Frame 36 of nfs-client.pcap has this interesting string:
> >> 
> >> 0ff0  00 01 3b f6 fb b6 26 16 8f 7c 00 00 00 41 62 74  
> >> ..;...&..|...Abt 1000  72 66 73 2d 32 30 00 00 00 00 00 00 00 00 30 36 
> >>  rfs-20........06 1010  2d 66 69 78 2d 64 65 61 64 6c 6f 63 6b 2d 77 68
> >>   -fix-deadlock-wh 1020  65 6e 2d 6d 6f 75 6e 74 69 6e 67 2d 61 2d 64
> >> 65   en-mounting-a-de 1030  67 72 61 64 65 64 2d 66 73 2e 70 61 74 63
> >> 68 00   graded-fs.patch.
> > 
> > Yes, that looks like the server messing up the encoding of the reply.
> > 
> > Holger, what's the difference between nfs-client.pcap and
> > nfs-server.pcap?
> 
> One is the client, one is the server :-)
> 
> No, really. Both 3.18.1, 64it, same userland/compiler/etc. and even same 
> CFLAGS for both kernel and userland. I built tcpdump on both (from 
> packages) and ran them back to back literally 10 seconds apart.

So this is two separate tests, both failed, the only difference is that
the tcpdump was run on the client in one case and the server in the
other?

> What "encoding" are we talking about here? The NFS RPC encoding?
> (everything I know & remember about NFS is 15+ years old..)

Right, I suspect there's a bug in the server's encoding of the reply to
the READDIR rpc.  Odd that the encoding would look correct from the
point of view of tcpdump on the server but not from the point of view of
tcpdump on the client.

--b.
