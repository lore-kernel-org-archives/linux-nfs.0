From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/AFS/Selinux issues with 2.26.29
Date: Thu, 26 Mar 2009 15:40:52 -0400
Message-ID: <1238096452.13095.22.camel@heimdal.trondhjem.org>
References: <49CAAB9B.5070104@linux.vnet.ibm.com>
	 <1238020424.26487.81.camel@heimdal.trondhjem.org>
	 <49CACF78.80305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:46154 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755572AbZCZTk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 15:40:59 -0400
In-Reply-To: <49CACF78.80305@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-03-25 at 17:42 -0700, Richard A Nelson wrote:
> Trond Myklebust wrote:
> > On Wed, 2009-03-25 at 15:09 -0700, Richard A Nelson wrote:
> >> 1) 2.6.29 NFS clients can no longer lock files:
> ...
> > 
> > Given that you are claiming to be seeing selinux problems on
> > 2.6.29-based servers, 
> 
> Yeah, I fixed the SeLinux issues by disabling it at boot
> 
> > could you therefore please check again after
> > downgrading the server kernel?
> 
> I dropped the server to:
> # uname -a
> Linux el-ghor 2.6.28.8 #19 SMP Sun Mar 22 18:41:28 UTC 2009 x86_64 GNU/Linux
> 
> And still see same lockfile error.
> 
> However, a typo showed that locking is indeed working fine - for everything
> except one directory tree (/root/Mail) ... re-mounting and even rebooting one
> of the failing clients didn't help.
> 
> mounts are nfs3,sec=sys,posix,... and the server filesystem is ext3 w/acls
> rpc.statd is active on all systems, and there is no firewall in the way
> 
> So now the server and one client have been rebooted, and the client can
> lock files anywhere but the directory tree for /root/Mail
> sm-notify -f (from the client) didn't help
> 
> Somewhere, there is persistant state that is keeping two out of three
> local systems from creating locks and it all started after upgrading the
> kernel ... colour me dazed and confused, but trying to continue ;)
> 
> /me goes in search of lock display tools (cat /proc/locks isn't yet enough for me)

Have you used wireshark to inspect what is going down the wire when this
exclusive create attempt fails? That would help in narrowing down
whether it is the client or the server that is being problematic.

Cheers
  Trond

