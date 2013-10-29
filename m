Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44494 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3J2RBF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 13:01:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfs.man: add description of multiple sec= options
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <310B7CD4-FDE2-420A-AFE6-C798BA70BE90@netapp.com>
Date: Tue, 29 Oct 2013 13:00:57 -0400
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <A9BA0018-D9E2-4F67-830F-24D7104094EE@oracle.com>
References: <1383064066-1139-1-git-send-email-dros@netapp.com> <27470170-8177-4561-A11A-70CA2EF704A8@oracle.com> <310B7CD4-FDE2-420A-AFE6-C798BA70BE90@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 12:40 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> 
> On Oct 29, 2013, at 12:30 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Oct 29, 2013, at 12:27 PM, Weston Andros Adamson <dros@netapp.com> wrote:
>> 
>>> The client now supports multiple sec= options as a colon delimited list.
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> utils/mount/nfs.man | 7 ++++---
>>> 1 file changed, 4 insertions(+), 3 deletions(-)
>>> 
>>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>>> index 2a42b93..17b8d88 100644
>>> --- a/utils/mount/nfs.man
>>> +++ b/utils/mount/nfs.man
>>> @@ -380,9 +380,10 @@ If a value of zero is specified, the
>>> .BR mount (8)
>>> command exits immediately after the first failure.
>>> .TP 1.5i
>>> -.BI sec= flavor
>>> -The security flavor to use for accessing files on this mount point.
>>> -If the server does not support this flavor, the mount operation fails.
>>> +.BI sec= flavors
>>> +A colon-delimited list of security flavors to use for accessing files on
>>> +this mount point. If the server does not support any of these flavors,
>>> +the mount operation fails.
>> 
>> Just a nit:  The new text kind of suggests that the colons are required.  "sec=single flavor" is also still supported.  Typically man page language is careful to show both.
> 
> Good point.
> 
> Should there be separate sections or should we do something like:
> 
> sec=flavor(s)
> 
> The  security flavor or flavors to use for accessing files on this
> mount point.  Multiple security flavors may be specified as a
> colon-delimited list. If the server does not support any of these flavors 
> the mount operation fails.

The current text is:

       sec=flavor     The security flavor to use for accessing files  on  this  mount
                      point.   If  the server does not support this flavor, the mount
                      operation fails.  If sec= is not specified, the client attempts
                      to  find  a security flavor that both the client and the server
                      supports.  Valid flavors are none, sys, krb5, krb5i, and krb5p.
                      Refer to the SECURITY CONSIDERATIONS section for details.

You might consider:

> sec=flavorlist
> 
> The security flavor or flavors to use when accessing files on this mount point.  Multiple flavors are specified as a colon-delimited list.  If sec= is not specified, the mount's security flavor list contains all security flavors the client supports.
> 
> The client chooses the strongest flavor on this list that is supported by the export's security policy.  If the server does not support any of these flavors, the mount operation fails.
> 
> Valid flavors are ....


I think my description of the negotiation strategy could be made more accurate, and you should mention how (whether?) flavor list ordering works.  Do you feel this is too much for a single section?  Some detail can be moved to SECURITY CONSIDERATIONS.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




