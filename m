From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/5] NFS: NFS_V4 and NFSD_V4 should depend on SUNRPC_GSS
Date: Mon, 17 Mar 2008 14:31:44 -0400
Message-ID: <1205778704.11303.95.camel@heimdal.trondhjem.org>
References: <20080314181525.29889.35370.stgit@manray.1015granger.net>
	 <1205769601.11303.10.camel@heimdal.trondhjem.org>
	 <0951705D-9F24-4E6F-B034-255C1A6655DB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420AbYCQSb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2008 14:31:59 -0400
In-Reply-To: <0951705D-9F24-4E6F-B034-255C1A6655DB@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-03-17 at 12:59 -0400, Chuck Lever wrote:
> > Selecting SUNRPC_GSS is _not_ equivalent to what we have today.
> > Currently, if you select NFSv4, it will force compilation of the
> > KerberosV mechanism too. AFAICS, this patch regresses that behaviour.
> 
> 
> Enforcing that behavior breaks the rules of Kconfig.

The current _implementation_ may break the rules, but the behaviour is
definitely correct and should not be changed.

> The purpose of Kconfig is to allow the kernel to build correctly.   
> The resulting configuration does not have to make sense from a run- 
> time perspective.

While Kconfig may allow it, that still doesn't make it a good policy.

> Normally the way this sort of thing is handled is that a note is left  
> in the help text that says "Oh, and you will find enabling Kerberos V  
> support useful since the spec requires it."  Adding a "default m &&  
> (NFSV4 || NFSD_V4)" or something like that under Kerberos GSS might  
> work as well.

config RPCSEC_GSS_KRB5
	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
	depends on SUNRPC && EXPERIMENTAL
	default y if (NFS_V4 && NFS_FS=y) || (NFSD_V4 && NFSD=y)
	default m if (NFS_V4 && NFS_FS=m) || (NFSD_V4 && NFSD=m)
	select ...

> But the point is, what I'm removing is not a build dependency; what  
> I'm replacing it with is a build dependency.

See above. "It compiles but doesn't run" isn't acceptable.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
