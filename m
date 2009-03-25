From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/AFS/Selinux issues with 2.26.29
Date: Wed, 25 Mar 2009 18:33:44 -0400
Message-ID: <1238020424.26487.81.camel@heimdal.trondhjem.org>
References: <49CAAB9B.5070104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33622 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752098AbZCYWdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 18:33:54 -0400
In-Reply-To: <49CAAB9B.5070104@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-03-25 at 15:09 -0700, Richard A Nelson wrote:
> 1) 2.6.29 NFS clients can no longer lock files:
>    #strace -f lockfile fubar
>    ...
>    uname({sys="Linux", node="gothic-ave", ...}) = 0
>    lstat64("_V0H.jaqyJB.gothic-ave", 0xbfdac9ec) = -1 ENOENT (No such file or directory)
>    open("_V0H.jaqyJB.gothic-ave", O_WRONLY|O_CREAT|O_EXCL|O_LARGEFILE, 0444) = -1 EINVAL (Invalid argument)
>    write(2, "lockfile: ", 10lockfile: )              = 10
>    write(2, "Try praying", 11Try praying)             = 11
>    write(2, ", giving up on \"", 16, giving up on ")       = 16
>    write(2, "fubar", 5fubar)                    = 5
>    write(2, "\"\n", 2"
> 
>    clients still on 2.6.28 and lower work fine ... the server *is* 2.26.29

lockfile works fine for me, both on NFSv3 and NFSv4 against my NetApp
filers, and as far as I can remember, there have been no changes to the
exclusive create code in the 2.6.29 client.

Given that you are claiming to be seeing selinux problems on
2.6.29-based servers, could you therefore please check again after
downgrading the server kernel?

Trond

