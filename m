Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29310 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573Ab1FHUlN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 16:41:13 -0400
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Date: Wed, 8 Jun 2011 16:41:00 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <41FD62D9-1CAA-46CA-B2D7-2F52E58A917B@oracle.com>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 8, 2011, at 1:39 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.

  [ ... snipped ... ]

> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
> index 9af2543..3822b4b 100644
> --- a/support/include/sockaddr.h
> +++ b/support/include/sockaddr.h
> @@ -46,6 +46,12 @@ union nfs_sockaddr {
> 	struct sockaddr_in6	s6;
> };
> 
> +struct local_bind_info {
> +	struct sockaddr_storage addr;

For storing socket addresses, nfs_utils has "union nfs_sockaddr" which safely allows the equivalent of type-casting.  You should use that here.

> +	int addrlen;

socklen_t or size_t is preferred for sockaddr lengths.

> +	int is_set;

This should probably be _Bool or bool.

But why is this structure needed?  Why can't you pass a bind address via a struct sockaddr * just as bind(2) does?

When you specify a source address for mountd and statd, wouldn't they need to register that address with rpcbind? That won't work for non-TI-RPC builds, and neither would it work for the kernel, which, according to Trond, will never support listening on specific addresses (he NACKed a patch to the kernel's rpcbind client to support this). Are you sure you need server-side changes too?

You can't pass a bind address to the mount command using a command line option, since command line options aren't stored in /etc/fstab or /etc/mtab.  How would umount.nfs learn of the bind address if it can't find it in /etc/mtab?

It should not read from an environment variable either... how would that work during system boot?  How would such a variable be set during system shutdown?  If we were to do this, it really should use a new mount option.

If you repost, I would do mountd, statd, and mount's getport implementation all in separate patches.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




