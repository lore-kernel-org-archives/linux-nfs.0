Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49684 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754640Ab0HCJL6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 05:11:58 -0400
Date: Tue, 3 Aug 2010 02:11:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Cc: andyc.bluearc@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        eric.dumazet@gmail.com, William.Allen.Simpson@gmail.com,
        gilad@codefidence.com, ilpo.jarvinen@helsinki.fi,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet
 loss
Message-Id: <20100803021110.f0b3877b.akpm@linux-foundation.org>
In-Reply-To: <20100803.012144.267950450.davem@davemloft.net>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com>
	<20100803.012144.267950450.davem@davemloft.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(cc linux-nfs)

On Tue, 03 Aug 2010 01:21:44 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: "Andy Chittenden" <andyc.bluearc@gmail.com>
> Date: Tue, 3 Aug 2010 09:14:31 +0100
> 
> > I don't know whether this patch is the correct fix or not but it enables the
> > NFS client to recover.
> > 
> > Kernel version: 2.6.34.1 and 2.6.32.
> > 
> > Fixes <https://bugzilla.kernel.org/show_bug.cgi?id=16494>. It clears down
> > any previous shutdown attempts so that reconnects on a socket that's been
> > shutdown leave the socket in a usable state (otherwise tcp_sendmsg() returns
> > -EPIPE).
> 
> If the SunRPC code wants to close a TCP socket then use it again,
> it should disconnect by doing a connect() with sa_family == AF_UNSPEC
