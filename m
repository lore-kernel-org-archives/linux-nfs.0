Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36663 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHYSqU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 14:46:20 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFSv4: Force a post-op attribute update when holding a delegation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSUazMz3P4c5SEaQV7bsg_DQnFU+FVbwF8vOP30JG8Nbw@mail.gmail.com>
Date: Tue, 25 Aug 2015 14:46:16 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BA97AFA6-F2ED-4A35-8A28-CC9378CA6B03@oracle.com>
References: <1440122378-30452-1-git-send-email-trond.myklebust@primarydata.com> <0BEC962F-39D5-410E-9B75-ED9EE98FFC56@oracle.com> <CAHQdGtRsWchQG9ct-Prxy7-PZyw8-jRC6f8fMJvkzxpd58WWpA@mail.gmail.com> <8C420AF0-BD66-4FFD-B3FF-660A264A03B0@oracle.com> <CAHQdGtSUazMz3P4c5SEaQV7bsg_DQnFU+FVbwF8vOP30JG8Nbw@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 25, 2015, at 2:41 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Tue, Aug 25, 2015 at 2:18 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Aug 25, 2015, at 1:04 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> On Tue, Aug 25, 2015 at 12:31 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>> On Aug 20, 2015, at 9:59 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>> 
>>>>> If the ctime or mtime or change attribute have changed because
>>>>> of an operation we initiated, we should make sure that we force
>>>>> an attribute update. However we do not want to mark the page cache
>>>>> for revalidation.
>>>> 
>>>> I've tested your linux-next branch (tip is aebbe9d73169
>>>> ("NFS41/flexfiles: zero out DS write wcc") against Solaris 12
>>>> with write delegation enabled (over RDMA, even!).
>>>> 
>>>> I was not able to reproduce the write append failures I saw
>>>> before.
>>>> 
>>> 
>>> Perfect. Thanks for testing!
>> 
>> Would it be possible to label some of these for stable?
>> 
> 
> I think this one is the only one that is missing such a label. I've
> reworded the commit message and pushed out a revised patch.

Not related to the write append problem, but I've also seen
missing opens on delegated files during reboot recovery in
4.0 kernels. Olga reported it before I got to it.

Is that one also appropriate for stable?


--
Chuck Lever



