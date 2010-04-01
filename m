From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 11/11] lockd: Allow mount option to specify caller_name
Date: Thu, 01 Apr 2010 15:45:36 -0400
Message-ID: <1270151136.13329.8.camel@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
	 <20100401190400.6395.52787.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33740 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222Ab0DATpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 15:45:41 -0400
In-Reply-To: <20100401190400.6395.52787.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-04-01 at 15:04 -0400, Chuck Lever wrote: 
> NLMPROC_LOCK requests have a "caller_name" argument which is supposed
> to contain the hostname the server uses to call the client back.
> Linux simply stuffs the system's utsname in this field, but this is
> not always the correct choice.  For example:
> 
>   o  If an unqualified hostname is used for the client's utsname,
>      it could be ambiguous when the server tries to resolve it
>   o  If the client's actual hostname is determined by DHCP, it may
>      not match its utsname
>   o  If the NFS mount was done in a network namespace, the namespace
>      name won't match the client's utsname
>   o  If the client has multiple network interfaces, it should provide
>      a hostname that matches the source address used to contact the
>      server
> 
> In all of these cases, user space can determine the correct value of
> the caller_name argument at mount time.
> 
> So, add a mount option that allows user space to specify the value of
> the caller_name argument of NLMPROC_LOCK requests.  If not specified,
> the kernel continues to use the init utsname, as before.

This argument makes no sense. Mount points do _not_ follow network
namespace boundaries, so making this hostname of yours a mount option
will make matters worse, not better.

Furthermore, even if we were to accept your argument, you are not
matching nfs_clients to your "namespace name", so if you do have more
than 1 mount to the same server but from different namespaces, then the
namespace name of the first to mount will automatically become the
default for the second mount too.

Trond

