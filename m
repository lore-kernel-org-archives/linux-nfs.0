From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount.nfs: silently fails with bad version arguments
Date: Thu, 03 Jun 2010 08:32:24 -0400
Message-ID: <4C07A0D8.4010808@RedHat.com>
References: <1275486084-23899-1-git-send-email-steved@redhat.com> <1275486084-23899-2-git-send-email-steved@redhat.com> <4C06CE71.1020404@oracle.com> <4C079BE8.5010509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab0FCMc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 08:32:28 -0400
In-Reply-To: <4C079BE8.5010509-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2010 08:11 AM, Steve Dickson wrote:
> 
> 
> On 06/02/2010 05:34 PM, Chuck Lever wrote:
>> On 06/ 2/10 09:41 AM, Steve Dickson wrote:
>>> mount.nfs should not only fail when an invalid protocol
>>> option is used (as it does), it should also print a
>>> diagnostic identifying the problem.
>>>
>>> Signed-off-by: Steve Dickson<steved@redhat.com>
>>> ---
>>>   utils/mount/network.c |    4 ++++
>>>   1 files changed, 4 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index c541257..de1014d 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -1254,6 +1254,8 @@ nfs_nfs_version(struct mount_options *options,
>>> unsigned long *version)
>>>               nfs_error(_("%s: option parsing error\n"),
>>>                       progname);
>>
>> Watch out for case fall-through.  You need to add:
>>
>>             return 0;
>>
>> here.
> Ah I didn't see that... good catch... 
>>
>>>           case PO_BAD_VALUE:
>>> +            nfs_error(_("%s: invalid value for 'vers=' option"),
>>> +                    progname);
>>>               return 0;
>>>           }
>>>       case 4: /* nfsvers */
>>> @@ -1268,6 +1270,8 @@ nfs_nfs_version(struct mount_options *options,
>>> unsigned long *version)
>>>               nfs_error(_("%s: option parsing error\n"),
>>>                       progname);
>>
>> Case fall-through here as well.
>>
>>>           case PO_BAD_VALUE:
>>> +            nfs_error(_("%s: invalid value for 'nfsvers=' option"),
>>> +                    progname);
>>
>> Why wouldn't you also print a diagnostic if a numeric value was used,
>> but the value was out of range?
> It did not appear there was any guarantee that &tmp would have been filled
> with anything useful, especially with something like nfsvers=v3 is given.
> 
>>
>> And, what about similar cases in nfs_nfs_port(), nfs_nfs_program(),
>> nfs_mount_program(), nfs_mount_version(), and nfs_mount_port() ?
> I was just looking at the version and protocol options and I really
> didn't want to make things too verbose. Meaning we don't need to be printing
> two or three messages for one error... 
On second thought... it turns out making this work is not too bad..

steved.
