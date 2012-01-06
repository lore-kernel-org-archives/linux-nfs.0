Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:51162 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758968Ab2AFS3d convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 13:29:33 -0500
Subject: Re: Boot regression caused by commit 6829a048
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325871176.4629.35.camel@lappy>
Date: Fri, 6 Jan 2012 13:29:22 -0500
Cc: linux@razik.name, Trond.Myklebust@netapp.com,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Message-Id: <5A327123-1097-474C-A7F6-7C29BB71FCEE@oracle.com>
References: <1325871176.4629.35.camel@lappy>
To: Sasha Levin <levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2012, at 12:32 PM, Sasha Levin wrote:

> Hi all,
> 
> I've noticed a boot regression caused by commit 6829a048 ("NFS: Retry
> mounting NFSROOT") which has increased boot time by 95 seconds.
> 
> The scenario is as follows:
> - A virtual guest running under the KVM tool.
> - Guest is using kernel automatic IP DHCP configuration ("ip=dhcp").
> - Guest is booting from a 9p device (which is not detected as block,
> and gets mounted after NFS tries to do its mounts).
> - No NFS server at all, no NFS parameters passed to the guest kernel.
> 
> Under this scenario, theres an additional 95 second delay before NFS
> fails and tries to boot using 9p:
> 
> [...]
> [    6.505269] md: autorun ...
> [    6.506954] md: ... autorun DONE.
> [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
> [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> [...]
> 
> This probably happens since the NFS server isn't configured, so the
> bootserver is automatically assumed to be the DHCP server, and with the
> commit above we won't simply fail immediately when the NFS code fails
> connecting to it.
> 
> I'm not quite sure about the correct solution for this. While I can
> forcefully disable NFS, is it really the right solution? Should we be
> retrying a NFS server even if one wasn't specifically set?

What DHCP options are passed to the client?  You can specify the "nfsrootdebug" boot command line option to explore this a little more.

Typically ip= is used specifically with NFSROOT.  You might review Documentation/filesystems/nfs/nfsroot.txt to see if some combination of boot command line options gives more desirable behavior.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




