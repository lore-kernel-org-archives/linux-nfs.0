From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Fix umount.nfs
Date: Mon, 20 Apr 2009 08:11:54 -0400
Message-ID: <49EC668A.1000404@RedHat.com>
References: <20090417201021.14555.93852.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38743 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632AbZDTMPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2009 08:15:13 -0400
In-Reply-To: <20090417201021.14555.93852.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> This short series addresses a couple of problems found with
> umount.nfs.  See RH bugzilla 492598.
> 
> After this series is applied, umount.nfs will send UMNT requests from
> a privileged source port.  This appears to match the behavior of
> umount.nfs before nfs-utils 1.1.5, and is required when the "secure"
> export option is used on the server.
> 
> A minor problem with the value returned by nfs_mount_protocol() is
> also addressed.  This might affect umount.nfs and NFSv2/v3
> version/protocol fallback by sending MNT and UMNT requests using
> the wrong transport protocol.
> 
> ---
> 
> Chuck Lever (3):
>       umount.nfs: Fix return value of nfs_mount_protocol()
>       umount.nfs: Use a privileged port when sending UMNT requests
>       support: Provide an API for creating a privileged RPC client
> 
> 
>  support/include/nfsrpc.h |   11 +++-
>  support/nfs/rpc_socket.c |  140 ++++++++++++++++++++++++++++++++++++++++++++--
>  utils/mount/network.c    |    4 +
>  3 files changed, 145 insertions(+), 10 deletions(-)
> 
All three patched tested and committed.

steved.
