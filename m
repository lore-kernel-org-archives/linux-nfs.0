Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:42906 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772AbaJaOtS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 10:49:18 -0400
Received: by mail-ie0-f182.google.com with SMTP id rd18so1427756iec.13
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 07:49:17 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20141020135736.GB20301@arm.com>
Date: Fri, 31 Oct 2014 10:49:13 -0400
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-Id: <FE0552AE-5243-44D3-B661-B622C2D957C0@primarydata.com>
References: <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com> <20140923135938.GB28608@arm.com> <20140923145356.GD28608@arm.com> <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com> <FA11FBE3-42E7-46B9-B9DA-FAE368DCE96B@primarydata.com> <F632C770-3E3D-4FC5-BBF3-69BB1CCA8F0D@primarydata.com> <20140923152558.GG28608@arm.com> <20140925171545.GR20043@arm.com> <78B8153D-59B7-4DBE-8472-D83338F04338@primarydata.com> <6111EECC-C8C1-4605-98AD-0AF0E1B6DA59@primarydata.com> <20141020135736.GB20301@arm.com>
To: Will Deacon <will.deacon@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 20, 2014, at 9:57 AM, Will Deacon <will.deacon@arm.com> wrote:

> On Sat, Oct 11, 2014 at 02:32:29PM +0100, Weston Andros Adamson wrote:
>> Hey Will,
> 
> Hi again, Andros,
> 
>> I’ve been very busy, but I haven’t forgotten about your bug report!
> 
> No problem, I've been busy too. I just checked with -rc1 and I can reproduce
> the issue there too.
> 
>> I think the WARN_ON_ONCE is just wrong, there are cases where the
>> PG_INODE_REF flag is legitimately not set. The flag is set so that sub
>> requests can mimmic the parent request’s reference count.
>> 
>> Could you please run the reproducer again, unmount, then check the contents of
>> /proc/fs/nfsfs/servers?
> 
> Sure. I just tried this and that file is empty after unmounting.

Sorry for the delay (again) - I just got back from a two week holiday.

This is good news! I think we can safely remove this WARN_ON_ONCE and call it a
day… or maybe calling it a month is more accurate ;)

-dros

