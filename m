Return-Path: linux-nfs-owner@vger.kernel.org
Received: from foss-mx-na.foss.arm.com ([217.140.108.86]:45997 "EHLO
	foss-mx-na.foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbaJTN5c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 09:57:32 -0400
Date: Mon, 20 Oct 2014 14:57:37 +0100
From: Will Deacon <will.deacon@arm.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
Message-ID: <20141020135736.GB20301@arm.com>
References: <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com>
 <20140923135938.GB28608@arm.com>
 <20140923145356.GD28608@arm.com>
 <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com>
 <FA11FBE3-42E7-46B9-B9DA-FAE368DCE96B@primarydata.com>
 <F632C770-3E3D-4FC5-BBF3-69BB1CCA8F0D@primarydata.com>
 <20140923152558.GG28608@arm.com>
 <20140925171545.GR20043@arm.com>
 <78B8153D-59B7-4DBE-8472-D83338F04338@primarydata.com>
 <6111EECC-C8C1-4605-98AD-0AF0E1B6DA59@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6111EECC-C8C1-4605-98AD-0AF0E1B6DA59@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 11, 2014 at 02:32:29PM +0100, Weston Andros Adamson wrote:
> Hey Will,

Hi again, Andros,

> I’ve been very busy, but I haven’t forgotten about your bug report!

No problem, I've been busy too. I just checked with -rc1 and I can reproduce
the issue there too.

> I think the WARN_ON_ONCE is just wrong, there are cases where the
> PG_INODE_REF flag is legitimately not set. The flag is set so that sub
> requests can mimmic the parent request’s reference count.
> 
> Could you please run the reproducer again, unmount, then check the contents of
> /proc/fs/nfsfs/servers?

Sure. I just tried this and that file is empty after unmounting.

Will
