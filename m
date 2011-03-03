Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758655Ab1CCUiT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 15:38:19 -0500
Message-ID: <4D6FFC37.9040409@RedHat.com>
Date: Thu, 03 Mar 2011 15:38:15 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Karel Zak <kzak@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/2] mount: Allow 'port=0' to be a valid port value.
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <4D6FF466.2070004@RedHat.com> <0B360A89-0FE0-4DB9-92C4-0EE59B1C2B75@oracle.com> <8C4D7A5C-3611-42AE-883E-59BA3C769041@oracle.com>
In-Reply-To: <8C4D7A5C-3611-42AE-883E-59BA3C769041@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/03/2011 03:16 PM, Chuck Lever wrote:
> 
> On Mar 3, 2011, at 3:12 PM, Chuck Lever wrote:
> 
>> Hi Steve-
>>
>> On Mar 3, 2011, at 3:04 PM, Steve Dickson wrote:
>>
>>> With the new util-linux, /etc/mtab is now is symbolically linked
>>> to /proc/mounts. In /proc/mounts, the 'port=0' exits which causes
>>> the umount.nfs to error out with the following error:
>>>  umount.nfs: invalid value for 'port=' option
>>>
>>> Setting port=0 is a valid value. It just means go out and query
>>> remote rpcbind to get the correct port.
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> Why are you signing off on this?  I sent you this patch weeks ago.  (In fact my version of the patch also fixes this problem in nfs_mount_port() as well).
> 
> Could have been lost in the shuffle... we were all traveling.  Anyway, you need to fix this in  () too.
Yeah... I don't see it... but see your point WRT nfs_mount_port()

steved.
> 
> 
>>
>>> ---
>>> utils/mount/network.c |    2 +-
>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index 8049c1a..88ab222 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -1346,7 +1346,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
>>> 	case PO_NOT_FOUND:
>>> 		break;
>>> 	case PO_FOUND:
>>> -		if (tmp >= 1 && tmp <= 65535) {
>>> +		if (tmp >= 0 && tmp <= 65535) {
>>> 			*port = tmp;
>>> 			return 1;
>>> 		}
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
