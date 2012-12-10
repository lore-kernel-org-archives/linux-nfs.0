Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59363 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab2LJMeO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 07:34:14 -0500
Date: Mon, 10 Dec 2012 07:34:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/7] nfsd: cleanup "init_net" references
Message-ID: <20121210123413.GA13327@fieldses.org>
References: <20121210091832.8855.26672.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121210091832.8855.26672.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 10, 2012 at 12:18:59PM +0300, Stanislav Kinsbursky wrote:
> Hard-coded "init_net" pointer is widely used in NFSd code.
> This patch replaces "init_net" references by passed struct net pointer where
> requied.
> In future, proper network namespace context will be taken from NFSd file
> system superblock private data or, where it's impossible, from current.

Thanks, applying.--b.

> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (7):
>       nfsd: use "init_net" for portmapper
>       nfsd: pass net to nfsd_init_socks()
>       nfsd: pass net to nfsd_startup() and nfsd_shutdown()
>       nfsd: pass net to nfsd_create_serv()
>       nfsd: pass net to nfsd_svc()
>       nfsd: pass net to nfsd_set_nrthreads()
>       nfsd: pass net to __write_ports() and down
> 
> 
>  fs/nfsd/nfsctl.c |   27 +++++++++++++++------------
>  fs/nfsd/nfsd.h   |    6 +++---
>  fs/nfsd/nfssvc.c |   35 ++++++++++++++---------------------
>  3 files changed, 32 insertions(+), 36 deletions(-)
> 
