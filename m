From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Make mount.nfs use new getport() function
Date: Tue, 02 Dec 2008 10:22:10 -0500
Message-ID: <493552A2.5020002@RedHat.com>
References: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49550 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544AbYLBPYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2008 10:24:30 -0500
In-Reply-To: <20081201183616.10436.71066.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> Four new IPv6-related patches for mount.nfs.  These replace the
> existing PMAP_GETPORT implementation in utils/mount/network.c with a
> call to the new library functions we just added.
> 
> The probe_statd() function is used by both the legacy and the text-
> based paths, but replacing the mount.nfs command's getport() function
> affects only the *legacy* NFS mount path, not text-based mounts.
> 
> For anyone testing this code, please try it on pre-2.6.23 kernels,
> or patch mount.nfs to use legacy binary style mounts.  This will
> exercise the new PMAP_GETPORT implementation using all the special
> cases needed by mount.nfs.
> 
> The new RPCB_GETADDR implementation will not be used until mount.nfs
> can pass in IPv6 addresses.
> 
> ---
> 
> Chuck Lever (4):
>       mount command: remove local getport() implementation
>       mount command: Replace clnt_ping() and getport() calls in probe_port()
>       mount command: Use nfs_error() instead of perror()
>       mount command: Use nfs_pmap_getport() in probe_statd()
Tested and Committed....

steved.
