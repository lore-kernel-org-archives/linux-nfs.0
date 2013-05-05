Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31163 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185Ab3EEWqG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 May 2013 18:46:06 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 1/2] NFSv4.x: Fix handling of partially delegated locks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <361E61FA-0F58-465D-85CD-63F6B4C1C6BE@oracle.com>
Date: Sun, 5 May 2013 18:46:06 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <73539653-2296-4D79-A954-2A04220B28A3@oracle.com>
References: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com> <9873A24B-BCB9-4F95-9EC7-0DE38513505D@oracle.com> <1367597884.3556.6.camel@leira.trondhjem.org> <361E61FA-0F58-465D-85CD-63F6B4C1C6BE@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 3, 2013, at 3:17 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 3, 2013, at 12:18 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Fri, 2013-05-03 at 12:12 -0400, Chuck Lever wrote:
>>> Hi-
>>> 
>>> On May 2, 2013, at 1:19 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> 
>>>> If a NFS client receives a delegation for a file after it has taken
>>>> a lock on that file, we can currently end up in a situation where
>>>> we mistakenly skip unlocking that file.
>>>> 
>>>> The following patch swaps an erroneous check in nfs4_proc_unlck for
>>>> whether or not the file has a delegation to one which checks whether
>>>> or not we hold a lock stateid for that file.
>>>> 
>>>> Reported-by: Chuck Lever <Chuck.Lever@oracle.com>
>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>> Cc: stable@vger.kernel.org
>>> 
>>> Although this patch may apply cleanly to, say, 3.0-stable, the result is that LOCKUs now never appear on the wire.  It seems that older stable kernels are missing something that is needed to make this simple fix work correctly.
>> 
>> Yes. There is a dependency on commit
>> 795a88c968eef031f370973512b42124bacb2f17 (NFSv4: Convert the
>> nfs4_lock_state->ls_flags to a bit field).
> 
> For the record, 795a88c9 appears in 3.7.  Thus the specific patch proposed in this thread applies to 3.7, 3.8, and 3.9.
> 
> We applied this patch to a 3.0-based kernel and then adjusted for the absence of 795a88c9.  It works as expected.  We'll also check as far back as 2.6.32.  More later.

2.6.32 suffers from this problem as well.  It appears that 2.6.34 is the oldest stable kernel that is currently maintained.

I've also confirmed that this issue exists in RHEL 6 (2.6.32-358 …).  I filed RH bugzilla 959788 to report the issue, provide a reproducer, and suggest the fix.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



