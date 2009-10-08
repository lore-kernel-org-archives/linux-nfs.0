From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] mount.nfs: Assume v2/v3 if mount-related options are present
Date: Thu, 8 Oct 2009 13:51:28 -0400
Message-ID: <5861547D-8C3E-4049-A78E-146E3DE01701@oracle.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173712.12619.45807.stgit@matisse.1015granger.net> <1255023929.11961.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:45710 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757880AbZJHRwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2009 13:52:42 -0400
In-Reply-To: <1255023929.11961.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 8, 2009, at 1:45 PM, Trond Myklebust wrote:

> On Thu, 2009-10-08 at 13:37 -0400, Chuck Lever wrote:
>> Don't try NFSv4 if any MNT protocol related options were presented by
>> the user.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> utils/mount/stropts.c |    7 +++++++
>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 0685caa..3401f63 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -564,6 +564,13 @@ static int nfs_try_mount_v4(struct  
>> nfsmount_info *mi)
>> 	}
>>
>> 	if (mi->version == 0) {
>> +		if (po_contains(options, "mounthost") ||
>> +		    po_contains(options, "mountaddr") ||
>> +		    po_contains(options, "mountvers") ||
>> +		    po_contains(options, "mountproto")) {
>> +			errno = EPROTONOSUPPORT;
>
> Shouldn't this be EINVAL ?

Since this is behind the mi->version == 0 check, we know that the user  
didn't specify an NFS version.  In any other v4 case, the kernel's  
mount option parser will kick these out with EINVAL.  But here, we  
just want to avoid trying to negotiate NFSv4.  So the EPROTONOSUPPORT  
return code will cause the logic in nfs_try_mount() to try v3/v2 next.

Basically the bug is this:  before, if I didn't specify an NFS  
version, but added some mountfoo= option, the mount.nfs command will  
try negotiating NFSv2/v3.  Now, it will try NFSv4 first, but these are  
illegal options for NFSv4, and the mount command will fail.  So,  
regression.  This new logic simply skips trying NFSv4 in this case.

>
>> +			goto out_fail;
>> +		}
>> 		if (po_append(options, "vers=4") == PO_FAILED) {
>> 			errno = EINVAL;
>> 			goto out_fail;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



