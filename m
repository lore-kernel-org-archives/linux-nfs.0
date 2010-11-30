Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61539 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753647Ab0K3Guw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 01:50:52 -0500
Message-ID: <4CF49FBA.2030601@cn.fujitsu.com>
Date: Tue, 30 Nov 2010 14:54:50 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <SteveD@redhat.com>, NFSv3 list <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mount: make sure mount correctly when kernel not support
 NFSv4
References: <4CEDFA23.5030103@cn.fujitsu.com> <96BE5F60-06F3-4CE9-8C1D-713992D3F246@oracle.com>
In-Reply-To: <96BE5F60-06F3-4CE9-8C1D-713992D3F246@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Chuck Lever :
> On Nov 25, 2010, at 12:54 AM, Mi Jinlong wrote:
> 
>> When user's nfs client(kernel) don't support NFSv4, maybe they build
>> kernel without NFSv4, there is a problem.
>>
>> When using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
>> filesystem, mount will fail and get error:
>>
>> "mount.nfs: an incorrect mount option was specified"
>>
>> as above, the mount should success, but it fail.
>>
>> When the mount command without specific NFS version, nfs-utils will
>> try to mount NFSv4 at first, but the kernel don't support, the kernel
>> will return with error EINVAL for parsing option (vers=4) fail.
> 
> Maybe the kernel should return EOPNOTSUPP in that case?

  Yes, what about the following patch.

--
thanks
Mi Jinlong
---------------------------------------------------------------------------------
