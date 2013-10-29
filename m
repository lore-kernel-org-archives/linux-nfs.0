Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51808 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3J2Qky convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 12:40:54 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <steved@redhat.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs.man: add description of multiple sec= options
Date: Tue, 29 Oct 2013 16:40:52 +0000
Message-ID: <310B7CD4-FDE2-420A-AFE6-C798BA70BE90@netapp.com>
References: <1383064066-1139-1-git-send-email-dros@netapp.com>
 <27470170-8177-4561-A11A-70CA2EF704A8@oracle.com>
In-Reply-To: <27470170-8177-4561-A11A-70CA2EF704A8@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 12:30 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Oct 29, 2013, at 12:27 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> 
>> The client now supports multiple sec= options as a colon delimited list.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> utils/mount/nfs.man | 7 ++++---
>> 1 file changed, 4 insertions(+), 3 deletions(-)
>> 
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index 2a42b93..17b8d88 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -380,9 +380,10 @@ If a value of zero is specified, the
>> .BR mount (8)
>> command exits immediately after the first failure.
>> .TP 1.5i
>> -.BI sec= flavor
>> -The security flavor to use for accessing files on this mount point.
>> -If the server does not support this flavor, the mount operation fails.
>> +.BI sec= flavors
>> +A colon-delimited list of security flavors to use for accessing files on
>> +this mount point. If the server does not support any of these flavors,
>> +the mount operation fails.
> 
> Just a nit:  The new text kind of suggests that the colons are required.  "sec=single flavor" is also still supported.  Typically man page language is careful to show both.

Good point.

Should there be separate sections or should we do something like:

sec=flavor(s)

The  security flavor or flavors to use for accessing files on this
mount point.  Multiple security flavors may be specified as a
colon-delimited list. If the server does not support any of these flavors 
the mount operation fails.

...

-dros

> 
> 
>> If
>> .B sec=
>> is not specified, the client attempts to find
>> -- 
>> 1.8.3.1 (Apple Git-46)
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com

