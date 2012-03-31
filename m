Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:33202 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760147Ab2CaP1q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Mar 2012 11:27:46 -0400
Subject: Re: [PATCH] nfs: Don't try mounting device as nfs root unless type fully matches
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CA+1xoqdQPi53GYr_Q6RtECJJcrz0TVVp4uNQX6jkfbQWQSNF7g@mail.gmail.com>
Date: Sat, 31 Mar 2012 11:27:33 -0400
Cc: Jim Rees <rees@umich.edu>, Sasha Levin <levinsasha928@gmail.com>,
        Lukas Razik <linux@razik.name>, Pekka Enberg <penberg@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>
Message-Id: <D3642511-B29B-4CA7-A133-C99B711954C1@oracle.com>
References: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com> <5FF522E0-132E-4A6A-A40F-5CCD08AF800A@oracle.com> <20120107181221.GA3777@umich.edu> <1326111265.30169.5.camel@lappy> <CA+1xoqdQPi53GYr_Q6RtECJJcrz0TVVp4uNQX6jkfbQWQSNF7g@mail.gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops.  Trond?  This got dropped somewhere.


On Mar 31, 2012, at 11:21 AM, Sasha Levin wrote:

> ping? I saw that this one didn't get pulled into the tree.
> 
> On Mon, Jan 9, 2012 at 1:14 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
>> On Sat, 2012-01-07 at 13:12 -0500, Jim Rees wrote:
>>> Chuck Lever wrote:
>>> 
>>>   On Jan 7, 2012, at 4:12 AM, Sasha Levin wrote:
>>> 
>>>   > Currently, we'll try mounting any device who's major device number is
>>>   > UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
>>>   > as 9p devices) but it wouldn't cause any issues since mounting the device
>>>   > as NFS would fail quickly and the code proceeded to doing the proper mount:
>>>   >
>>>   >   [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
>>>   >   [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
>>>   >
>>>   > Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
>>>   > mounting NFS root, which means that now we don't immediately fail and instead
>>>   > it takes an additional 90+ seconds until we stop retrying.
>>>   >
>>>   > This meant that it would take an additional 90 seconds to boot when we're not
>>>   > using a device type which gets detected in order before NFS.
>>> 
>>>   The long timeouts are kind of irrelevant, in my view.  The real problem is
>>>   that NFS was tried at all in this case.  That behavior was not introduced
>>>   by 6829a058.
>>> 
>>> The comment does imply that 6829a048 introduced a bug, but that's not true.
>>> It uncovered a bug that was there before.
>>> 
>>> I would change the part about "now we don't immediately fail."  It didn't
>>> immediately fail before, but the timeout was short enough that you wouldn't
>>> notice it.
>> 
>> I tried to point out that 6829a048 changed the behavior which was
>> described in the first paragraph, I didn't try to imply that 6829a048 is
>> buggy on its own.
>> 
>> I'm fine with changing the changelog to whatever will make it clearer.
>> 
>> --
>> 
>> Sasha.
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




