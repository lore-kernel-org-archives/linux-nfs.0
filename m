From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/31] mount.nfs patches for next nfs-utils release
Date: Wed, 15 Jul 2009 09:50:22 -0400
Message-ID: <4A5DDE9E.9040001@RedHat.com>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51997 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbZGONxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2009 09:53:41 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/29/2009 01:34 PM, Chuck Lever wrote:
> Hi Steve-
> 
> This series contains some patches I've had for a little while, and a
> bunch of new fixes I made last week to address RH bugzillas 486266 and
> 505535.
> 
> In the short term, these patches should address most of the recent
> complaints about the new mount.nfs.  Text-based mounts should behave
> a lot more like legacy mounts -- fewer hangs and better negotiation
> semantics.
> 
> Longer term, we are planning to sink the mount version/transport
> negotiation into the kernel.
> 
> ---
> 
> Chuck Lever (31):
>       mount.nfs: Squelch compiler warnings in nfs_strerror()
>       mount.nfs: Squelch unused parameter warnings on empty functions
>       mount.nfs: Fix compiler warning in stropts.c
>       umount.nfs: Use correct data type in nfsumount()
>       mount.nfs: remove unused @addrlen argument from nfs_string_to_sockaddr()
>       mount.nfs: Remove unused @salen parameter from nfs_ca_gai()
>       mount.nfs: Fix some nfs_error() nits in network.c
>       mount.nfs: Remove unused parameter in try_mount()
>       mount.nfs: Use correct data type in discover_nfs_mount_data_version()
>       support: Introduce sockaddr helpers to get and set IP port numbers
>       mount.nfs: Don't update extra_opts after text-based negotiation
>       mount.nfs: Clean up after restructuring version/protocol negotiation
>       mount.nfs: Clean up nfs_is_permanent_error()
>       mount.nfs: rearchitect mount version/protocol negotiation logic
>       mount.nfs: make nfs_options2pmap return errors
>       mount.nfs: force rpcbind queries if options aren't specified
>       mount.nfs: If port= specifies an unregistered port, retry, then fail
>       getport: Convert TCP connection refused to RPC_CANTRECV
>       getport: Restore historical TCP connect timeout error code
>       mount.nfs: Add more debugging output around nfs_getport()
>       getport: Clear shared error fields before trying rpcbind queries
>       getport: RPC_PROGNOTREGISTERED is a permanent error
>       support: Set proper retransmit timeout for datagram transports
>       support: Don't return RPC_UNKNOWNHOST from rpc_socket.c
>       support: Use HAVE_LIBTIRPC to switch in bindresvport_sa(3t)
>       New versions of libtool add extra aclocal scripts
>       getport: Remove unneeded @salen arguments
>       getport: replace getnameinfo(NI_NUMERICHOST) with inet_ntop(3)
>       getport: Remove AI_ADDRCONFIG from nfs_gp_loopback_address()
>       getport: RPCB_GETADDR's r_addr should contain rpcbind port, not zero
>       getport: RPCB_GETADDR r_owner should be an empty string
> 
Committed... a long with a couple more patches that cleaned up some 
error cases and the uses of uninitialised data... 

steved.
 
