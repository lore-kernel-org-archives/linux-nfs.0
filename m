Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab2ALUyg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 15:54:36 -0500
Date: Thu, 12 Jan 2012 15:54:33 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Dallas Clement <dallas.a.clement@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems restarting nfsd
Message-ID: <20120112155433.6e2a859b@tlielax.poochiereds.net>
In-Reply-To: <CAE9DZUQTFA8qqNtphJe6NQYqbbdi_8aMyDBgbJF1-=1arW3rCw@mail.gmail.com>
References: <CAE9DZUQTFA8qqNtphJe6NQYqbbdi_8aMyDBgbJF1-=1arW3rCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Jan 2012 19:11:09 -0600
Dallas Clement <dallas.a.clement@gmail.com> wrote:

> I've got a home-brew linux 2.6.39 kernel and I'm having some problems
> restarting nfsd.  If I stop it and wait > 10 seconds and then start
> it, it seems to behave, but if I stop/start in rapid succession, it
> will not start correctly and I see the following errors in dmesg:
> 
> [  182.130908] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state
> recovery directory
> [  182.130971] NFSD: starting 90-second grace period
> [  441.501954] nfsd: last server has exited, flushing export cache
> [  444.595519] svc: failed to register nfsdv2 RPC service (errno 111).
> [  444.595598] svc: failed to register nfsaclv2 RPC service (errno 111).
> [  444.595639] nfsd: last server has exited, flushing export cache
> [  444.596145] svc: failed to register nfsdv2 RPC service (errno 111).
> [  444.596201] svc: failed to register nfsaclv2 RPC service (errno 111).
> [  444.596250] nfsd: last server has exited, flushing export cache
> [  444.596494] nfsd: last server has exited, flushing export cache
> 
> Here is my kernel config:
> 
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> # CONFIG_ROOT_NFS is not set
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> # CONFIG_NFS_USE_NEW_IDMAPPER is not set
> CONFIG_NFSD=y
> CONFIG_NFSD_DEPRECATED=y
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V4=y
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> CONFIG_SUNRPC_GSS=y
> 
> I also have nfs-utils-1.2.5 installed on this system.
> 
> Any idea what could be going wrong?

111 is -ECONNREFUSED. Looks like the portmapper or rpcbind is refusing
connections?

-- 
Jeff Layton <jlayton@redhat.com>
