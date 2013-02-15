Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40602 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935864Ab3BOQUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 11:20:23 -0500
Date: Fri, 15 Feb 2013 11:20:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH v2 0/4] nfsd: make is works in a container
Message-ID: <20130215162021.GK8343@fieldses.org>
References: <20130201125210.3257.46454.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130201125210.3257.46454.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 01, 2013 at 03:56:05PM +0300, Stanislav Kinsbursky wrote:
> This patch set finally enables NFSd in container.
> I've tested it in container with it's own root, and also pid, net and mount
> namespaces.

Thanks, these look fine to me; applying.  They should show up in my
for-3.9 branch sometime today.

--b.

> 
> There are some limitations, which are listed below:
> 1) only nfsdclt client tracker supported for container. It's deprecated and
> going to be removed soon. UMH tracker requires switching root. Legacy tracker
> requires something like RB tree of opened inodes to make sure, that any
> recovery directory will be opened only once.
> 2) Enabled versions are controlled globally (should be fixed).
> 3) Server should be stopped by writing "0" to
> /proc/fs/nfsd/threads instead of sending signals to NFSd threads (they are
> working in init_pid). Sending signals will either won't work if container wich
> its own pid namespace, or will kill all nfsd threads for all containers in
> init_pid namesapce.
> 4) Currently, if container was stopped without stopping NFS server (i.e. it's
> init was killed), NFSd kthreads will remain running. One of possible solutions
> is to not hold network by NFSd service sockets, but register oer-net callback
> and kill all the threads on network namespace exit.
> 5) NFSd filesystem superblock holds network namespace. I.e. if some process
> will hold container's NFSd supeblock, then sthe whole container's network
> naemspace will stay alive even is container is destroyed already.
> 
> There may be more limitations, which are not clear to me yet.
> 
> v2:
> 1) removed root swap - deprecated
> 2) rebased on current tree
> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (4):
>       nfsd: containerize NFSd filesystem
>       nfsd: use proper net while reading "exports" file
>       nfsd: disable usermode helper client tracker in container
>       nfsd: enable NFSv4 state in containers
> 
> 
>  fs/nfsd/nfs4recover.c |    6 ++++
>  fs/nfsd/nfs4state.c   |   10 ------
>  fs/nfsd/nfsctl.c      |   77 +++++++++++++++++++++++++++++++++++++------------
>  fs/nfsd/nfssvc.c      |    5 +--
>  4 files changed, 66 insertions(+), 32 deletions(-)
> 
