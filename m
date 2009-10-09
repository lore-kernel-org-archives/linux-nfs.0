From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options
 are present
Date: Fri, 09 Oct 2009 11:12:34 -0400
Message-ID: <4ACF52E2.6060501@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173712.12619.45807.stgit@matisse.1015granger.net> <4ACF3AD1.2080802@RedHat.com> <9E475E97-ECCA-4CD1-9A35-63DEE3F63313@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758337AbZJIPNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 11:13:16 -0400
In-Reply-To: <9E475E97-ECCA-4CD1-9A35-63DEE3F63313@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/09/2009 11:03 AM, Chuck Lever wrote:
> 
> On Oct 9, 2009, at 9:29 AM, Steve Dickson wrote:
> 
>>
>>
>> On 10/08/2009 01:37 PM, Chuck Lever wrote:
>>> Don't try NFSv4 if any MNT protocol related options were presented by
>>> the user.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> utils/mount/stropts.c |    7 +++++++
>>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 0685caa..3401f63 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -564,6 +564,13 @@ static int nfs_try_mount_v4(struct nfsmount_info
>>> *mi)
>>>     }
>>>
>>>     if (mi->version == 0) {
>>> +        if (po_contains(options, "mounthost") ||
>>> +            po_contains(options, "mountaddr") ||
>>> +            po_contains(options, "mountvers") ||
>>> +            po_contains(options, "mountproto")) {
>>> +            errno = EPROTONOSUPPORT;
>>> +            goto out_fail;
>>> +        }
>> I think it make senses to assume the version negation should
>> start version 3 when  mountXXXX options exist instead of
>> failing a mount they probably didn't want..
> 
> Yes, that's exactly what this patch does.  NFSv4 negotiation is skipped
> if any mountfoo options are presented by the user.
> 
> It's arguable where to put this check.  This seemed like the most
> straightforward way to deal with it.
I guess a comment would have made it a bit clear... and I was thinking
the check should be made before the nfs_try_mount_v4() verses having
nfs_try_mount_v4() fail in a recoverable way...

steved.
