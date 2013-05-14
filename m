Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:30028 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab3ENRrS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 13:47:18 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r4EHlHiD000915
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 14 May 2013 17:47:18 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4EHlGAU004496
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 14 May 2013 17:47:17 GMT
Received: from abhmt106.oracle.com (abhmt106.oracle.com [141.146.116.58])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r4EHlGxS002485
	for <linux-nfs@vger.kernel.org>; Tue, 14 May 2013 17:47:16 GMT
Date: Tue, 14 May 2013 10:47:14 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix security flavor negotiation with legacy binary
 mounts
Message-ID: <20130514174714.GC29406@blackbox.djwong.org>
References: <20130514142620.37841.9591.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130514142620.37841.9591.stgit@seurat.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 10:26:20AM -0400, Chuck Lever wrote:
> Commit 4580a92d44 "NFS: Use server-recommended security flavor by
> default (NFSv3)" introduced a behavior regression for NFS mounts
> done via a legacy binary mount(2) call.

NFS mount with klibc nfsmount is working again with this patch, thank you!

You may add:
Tested-by: Darrick J. Wong <darrick.wong@oracle.com>

Though you might want to clarify in the commit message that it's really the
klibc nfsmount command, since that was really what was being called by busybox
& friends.

--D
> 
> Darrick J. Wong <darrick.wong@oracle.com> reports:
> 
> > I have a kvm-based testing setup that netboots VMs over NFS, the
> > client end of which seems to have broken somehow in 3.10-rc1.  The
> > server's exports file looks like this:
> >
> > /storage/mtr/x64	192.168.122.0/24(ro,sync,no_root_squash,no_subtree_check)
> >
> > On the client end (inside the VM), the initrd runs the following
> > command to try to mount the rootfs over NFS:
> >
> > # mount -o nolock -o ro -o retrans=10 192.168.122.1:/storage/mtr/x64/ /root
> >
> > (Note: This is the busybox mount command.)
> >
> > The mount fails with -EINVAL.
> 
> Ensure that a default security flavor is specified for legacy binary
> mounts, since they do not invoke nfs_select_flavor() in the kernel.
> 
> Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/super.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a366107..2d7525f 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1942,6 +1942,7 @@ static int nfs23_validate_mount_data(void *options,
>  		args->namlen		= data->namlen;
>  		args->bsize		= data->bsize;
>  
> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>  		if (data->flags & NFS_MOUNT_SECFLAVOUR)
>  			args->auth_flavors[0] = data->pseudoflavor;
>  		if (!args->nfs_server.hostname)
> @@ -2637,6 +2638,7 @@ static int nfs4_validate_mount_data(void *options,
>  			goto out_no_address;
>  		args->nfs_server.port = ntohs(((struct sockaddr_in *)sap)->sin_port);
>  
> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>  		if (data->auth_flavourlen) {
>  			if (data->auth_flavourlen > 1)
>  				goto out_inval_auth;
> 
