From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Option noac not working correctly?
Date: Wed, 18 Mar 2009 11:10:03 -0400
Message-ID: <1237389003.7275.9.camel@heimdal.trondhjem.org>
References: <49C106DD.2080008@bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Diego Moreno <Diego.Moreno-Lazaro@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44069 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945AbZCRPKK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2009 11:10:10 -0400
In-Reply-To: <49C106DD.2080008@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-03-18 at 15:36 +0100, Diego Moreno wrote:
> Hello everyone,
> 
> I've been testing the noac mount option in several kernels (2.6.27.10, 
> 2.6.29-rc8) for NFSv3 and NFSv4. The next commands do not work properly:
> 
> rm -f /export/B; ls -l /tmp/nfs_client_tcp/B ; uname -a > /export/B; ls 
> -l /tmp/nfs_client_tcp/B
> 
> Result is usually:
> 
> ls: /tmp/nfs_client_tcp/B: No such file or directory
> ls: /tmp/nfs_client_tcp/B: No such file or directory
> 
> Actually the result should be always:
> 
> ls: /tmp/nfs_client_tcp/B: No such file or directory
> -rw-r--r-- 1 root root 89 Mar 18 14:02 /tmp/nfs_client_tcp/B
> 
> Network traces show me that client is not making any lookup in the 
> server for the second 'ls'. A client with noac option should always make 
> a lookup on server, isn't it?
> 
> My /etc/exports file:
> 
> /export  *(rw,fsid=0,insecure,no_subtree_check)
> 
> Relevant information from cat /proc/mounts:
> 
> pwrd:/ /tmp/nfs_client_tcp nfs4 
> rw,sync,vers=4,rsize=1048576,wsize=1048576,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,nointr,noac,proto=tcp,timeo=600,retrans=2,sec=sys
> 
> NFS debug trace of the second ls command:
> 
> NFS call  access
> NFS: nfs_update_inode(0:17/2 ct=2 info=0x6)
> NFS reply access: 0
> NFS: permission(0:17/2), mask=0x1, res=0
> NFS: revalidating (0:17/2)
> NFS call  getattr
> NFS reply getattr: 0
> NFS: nfs_update_inode(0:17/2 ct=2 info=0x6)
> NFS: nfs3_forget_cached_acls(0:17/2)
> NFS: (0:17/2) revalidation complete
> NFS: nfs_lookup_revalidate(/B) is valid
> NFS: dentry_delete(/B, 8)
> 
> Is there anything I'm not doing well? Is this a known bug for the last 
> kernel version? Thanks,

The above behaviour is perfectly correct _if_ the mtime
on /tmp/nfs_client_tcp doesn't change between your 'rm' and the creation
of B. Given that most Linux filesystems have poor (1 second) resolution
on mtime, then for it not to change in the above test is an extremely
likely event.

Note that there is a better option for controlling lookup behaviour in
newer kernels: -olookupcache=all or -olookupcache=positive should both
cause your test above to pass irrespective of whether or not mtime
changed.

Trond

