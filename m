Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:31316 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3J2Qk3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 12:40:29 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfs.man: add description of multiple sec= options
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9534ED3E0@SACEXCMBX04-PRD.hq.netapp.com>
Date: Tue, 29 Oct 2013 12:40:17 -0400
Cc: Weston Andros Adamson <dros@netapp.com>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <B43CC736-DA71-4A68-B35A-C6A6BA53D28A@oracle.com>
References: <1383064066-1139-1-git-send-email-dros@netapp.com> <27470170-8177-4561-A11A-70CA2EF704A8@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9534ED3E0@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 12:36 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>> Sent: Tuesday, October 29, 2013 12:30 PM
>> To: Weston Andros Adamson
>> Cc: steved@redhat.com; linux-nfs@vger.kernel.org
>> Subject: Re: [PATCH] nfs.man: add description of multiple sec= options
>> 
>> 
>> On Oct 29, 2013, at 12:27 PM, Weston Andros Adamson <dros@netapp.com>
>> wrote:
>> 
>>> The client now supports multiple sec= options as a colon delimited list.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> utils/mount/nfs.man | 7 ++++---
>>> 1 file changed, 4 insertions(+), 3 deletions(-)
>>> 
>>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man index
>>> 2a42b93..17b8d88 100644
>>> --- a/utils/mount/nfs.man
>>> +++ b/utils/mount/nfs.man
>>> @@ -380,9 +380,10 @@ If a value of zero is specified, the .BR mount
>>> (8) command exits immediately after the first failure.
>>> .TP 1.5i
>>> -.BI sec= flavor
>>> -The security flavor to use for accessing files on this mount point.
>>> -If the server does not support this flavor, the mount operation fails.
>>> +.BI sec= flavors
>>> +A colon-delimited list of security flavors to use for accessing files
>>> +on this mount point. If the server does not support any of these
>>> +flavors, the mount operation fails.
>> 
>> Just a nit:  The new text kind of suggests that the colons are required.
>> "sec=single flavor" is also still supported.  Typically man page language is
>> careful to show both.
> 
> How about "colon-separated list of one or more security flavours"? That's less ambiguous than "colon-delimited"...

Maybe Dros could also update the EXAMPLES section with one of each.  Just a thought.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




