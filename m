From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/14] Support for mounting NFSv4 servers over IPv6
Date: Tue, 15 Jul 2008 15:31:47 -0400
Message-ID: <487CFB23.30008@RedHat.com>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497AbYGOTcc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 15:32:32 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Here is the latest version of the patches that add support to the text-
> based mount.nfs command for mounting NFSv4 servers over IPv6.  This set
> replaces the set I sent a couple of days ago.
> 
> It was suggested that these be included in the next release of
> nfs-utils, 1.1.3.  Kernel support for these features (such as handling raw
> IPv6 NFS server addresses properly when mounting) is planned for 2.6.27, so
> inclusion of these patches would allow wider testing during .27's rc period.
> 
> Mounting NFSv2/v3 servers over IPv6 is more complex.  It requires support
> for a scalable rpcbind/portmap client built into nfs-utils, thus it is not
> included in the present patch series.  Anyone interested in looking at my
> current prototype for this can check out:
> 
>   http://git.linux-nfs.org/?p=cel/nfs-utils.git;a=summary
> 
> It includes all the patches in this series and the patches I posted last
> week for nfs-utils 1.1.3, client-side support for NFSv2/v3 mounting and
> unmounting over IPv6, a prototype IPv6-enabled sm-notify command, and
> updates to nfs(5) describing IPv6 support for the NFS client.
> 
> For what it's worth, I'll be on holiday next week, but I can field any
> questions or comments before this Saturday, or when I return.
> 
> ---
> 
> Chuck Lever (14):
>       mount command: Remove RPC headers from network.h
>       text-based mount command: remove unnecessary headers from stropts.c
>       text-based mount options: rename functions in stropts.c
>       text-based mount command: Remove unused IPv4-only functions
>       text-based mount command: Support raw IPv6 address hostnames
>       text-based mount command: Add IPv6 support to set_mandatory_options
>       text-based mount command: "mounthost=" option support for IPv6 addresses
>       text-based mount command: "clientaddr=" option support for IPv6 addresses
>       text-based mount command: "addr=" option support for IPv6 addresses
>       text-based mount command: Add helper to construct network addresses
>       text-based mount command:  get_client_address support for IPv6
>       mount command: Add functions to manage addresses in string form
>       text-based mount command: Add headers needed for IPv6 support
>       nfs-utils: Introduce new ./configure option: "--enable-ipv6"
> 
All 14 patches have been committed...

steved.
