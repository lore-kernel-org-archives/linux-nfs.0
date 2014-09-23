Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:57740 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228AbaIWPC2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 11:02:28 -0400
Received: by mail-ie0-f177.google.com with SMTP id x19so9521169ier.22
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2014 08:02:28 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com>
Date: Tue, 23 Sep 2014 11:02:26 -0400
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Message-Id: <FA11FBE3-42E7-46B9-B9DA-FAE368DCE96B@primarydata.com>
References: <20140923130352.GK26472@arm.com> <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com> <20140923135938.GB28608@arm.com> <20140923145356.GD28608@arm.com> <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com>
To: Will Deacon <will.deacon@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 23, 2014, at 10:59 AM, Weston Andros Adamson <dros@primarydata.com> wrote:

> On Sep 23, 2014, at 10:53 AM, Will Deacon <will.deacon@arm.com> wrote:
> 
>> On Tue, Sep 23, 2014 at 02:59:38PM +0100, Will Deacon wrote:
>>> On Tue, Sep 23, 2014 at 02:33:06PM +0100, Weston Andros Adamson wrote:
>>>> Any more info on how to reproduce this would be really great. Unfortunately I don’t
>>>> have access to an arm64 system.
>>> 
>>> I've not spotted a pattern other than using 64k pages, yet. If I manage to
>>> get a reproducer, I'll let you know.
>>> 
>>>> If it’s possible, could we get a packet trace around when this happens? This is pure
>>>> speculation, but this might have something to do the resend path - a commit fails
>>>> and all the requests on the commit list have to be resent.
>>> 
>>> Sure, once I can reproduce it reliably, then I'll try to do that.
>> 
>> Right, a bunch of DDing from /dev/zero over an ssh session triggers this
>> very quickly. I've put a binary tcpdump here:
>> 
>> http://www.willdeacon.ukfsn.org/bitbucket/oopsen/nfs/tcpdump.bin
>> 
>> You may want to filter out the ssh packets. The only `interesting' thing to
>> me is a retransmission about half way through, but I don't know what I'm
>> looking for.
>> 
>> The NFS server is 10.1.203.204 and the client is 10.1.203.24.
> 
> Thanks! You are using NFSv2, so there are no commits - that rules out my hunch.

Wait a second - the whole point of this extra reference (that the WARN_ON_ONCE is
related to) is to handle the pass off to commit lists.

Maybe I’m just doing the wrong thing here with NFSv2!

More soon.

-dros

