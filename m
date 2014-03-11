Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752478AbaCKQGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 12:06:04 -0400
Message-ID: <531F3463.80404@RedHat.com>
Date: Tue, 11 Mar 2014 12:05:55 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid needing
 to write to /proc
References: <20140220063616.6548.42556.stgit@notabene.brown>
In-Reply-To: <20140220063616.6548.42556.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/20/2014 01:36 AM, Neil Brown wrote:
> There are a number of NFS-related setting that currently must be set
> by writing to various files under /proc.
> This is a bit clumsy, particularly for systemd unit files.
> 
> So this series adds options to a number of commands where relevant.
> 
> The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortable with.
> The third (nlm grace time) I think is probably right but if someone can argue
>  an alternate approach I'm unlikely to resist.
> The fourth is .... uhm.  You better look yourself.
> 
> Part of me thinks that nlm port numbers should be set in /etc/sysctl.conf (or sysctl.d)
> and /etc/modprobe.d should have something like
> 
>  install lockd  sysctl -p /etc/sysctl.d/lockd
> 
> but last time I tried that it broke "modprobe --show-depends".
> Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sysctl.d/lockd
> 
> Thoughts?
All 4 patches tested and committed... 

steved.

> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> Neil Brown (4):
>       nfsd: add -r and --rdma options to request rdma service.
>       nfsd: alloc nfsv4leasetime and nfsv4gracetime to be set.
>       nfsd: set nlm grace time to make NFSv4 grace time
>       statd: add options to set port number of lockd.
> 
> 
>  utils/nfsd/nfsd.c     |   52 +++++++++++++++++++++++++++++++++++++++----
>  utils/nfsd/nfsd.man   |   21 +++++++++++++++++
>  utils/nfsd/nfssvc.c   |   59 +++++++++++++++++++++++++++++++++++++++++++++++++
>  utils/nfsd/nfssvc.h   |    2 ++
>  utils/statd/statd.c   |   57 +++++++++++++++++++++++++++++++++++++++++++++--
>  utils/statd/statd.man |   24 ++++++++++++++++++--
>  6 files changed, 204 insertions(+), 11 deletions(-)
> 
