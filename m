Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13605 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096Ab1LYMsh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Dec 2011 07:48:37 -0500
Message-ID: <1324817295.5195.0.camel@lade.trondhjem.org>
Subject: Re: [PATCH] SUNRPC: make SUNPRC clients list per network namespace
 context
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Sun, 25 Dec 2011 13:48:15 +0100
In-Reply-To: <20111214081918.2804.59143.stgit@localhost6.localdomain6>
References: <20111214081918.2804.59143.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-12-14 at 12:19 +0300, Stanislav Kinsbursky wrote: 
> This patch moves static SUNRPC clients list and it's lock to sunrpc_net
> structure.
> Currently this list is used only for debug purposes. But later it will be used
> also for selecting clients by networks namespace on PipeFS mount/umount events.
> Per-network namespace lists will make this faster and simplier.
> 
> Note: client list is taken from "init_net" network namespace context in
> rpc_show_tasks(). This will be changed with making SUNRPC sysctl's per network
> namespace context.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

This doesn't seem to integrate with any of your patch series, and
conflicts with everything that touches netns.h, for instance...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

