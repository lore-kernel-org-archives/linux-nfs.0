From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: add and use nfs_authsys_create
Date: Mon, 01 Mar 2010 08:08:41 -0500
Message-ID: <4B8BBC59.3040809@RedHat.com>
References: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318Ab0CANIu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 08:08:50 -0500
In-Reply-To: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/19/2010 06:05 PM, Jeff Layton wrote:
> The current mount, umount and showmount code uses
> authunix_create_default to get an auth handle. The one provided by glibc
> returned a truncated list of groups when there were more than 16 groups.
> libtirpc however currently does an abort() in this case, which causes
> the program to crash and dump core.
> 
> nfs-utils just uses these auth handles for the MNT protocol, so the
> group list doesn't make a lot of difference here. Add a new function
> that creates an auth handle with a supplemental gids list that consists
> only of the primary gid. Have nfs-utils use that function anywhere that
> it currently uses authunix_create_default. Also, have the caller
> properly check for a NULL return from that function.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  support/include/nfsrpc.h    |    3 +++
>  support/nfs/rpc_socket.c    |   21 +++++++++++++++++++++
>  utils/mount/network.c       |   15 ++++++++++++---
>  utils/showmount/showmount.c |    8 +++++++-
>  4 files changed, 43 insertions(+), 4 deletions(-)
> 
>
Committed...

steved.
