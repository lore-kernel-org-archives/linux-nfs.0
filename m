From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 01/15] mountd: Clear mountd registrations at start up
Date: Thu, 14 Oct 2010 09:21:57 -0400
Message-ID: <4CB703F5.5030108@RedHat.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000411.6667.17979.stgit@ellison.1015granger.net> <4CB5C876.3030203@RedHat.com> <4CB5CC64.1060303@RedHat.com> <B4BCB06D-A992-407C-BD96-65E7AE1F0649@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286Ab0JNNWC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 09:22:02 -0400
In-Reply-To: <B4BCB06D-A992-407C-BD96-65E7AE1F0649@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/13/2010 04:12 PM, Chuck Lever wrote:
> 
> On Oct 13, 2010, at 11:12 AM, Steve Dickson wrote:
> 
>>
>>
>> On 10/13/2010 10:55 AM, Steve Dickson wrote:
>>>
>>>
>>> On 10/10/2010 08:04 PM, Chuck Lever wrote:
>>>> Clear stale MNT registrations before mountd tries to create fresh
>>>> listeners, to ensure that mountd starts.  This is also what statd
>>>> does.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> utils/mountd/mountd.c |    1 +
>>>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
>>>> index d309950..7e0cf6a 100644
>>>> --- a/utils/mountd/mountd.c
>>>> +++ b/utils/mountd/mountd.c
>>>> @@ -840,6 +840,7 @@ main(int argc, char **argv)
>>>> 	if (new_cache)
>>>> 		cache_open();
>>>>
>>>> +	unregister_services();
>>>> 	if (version2()) {
>>>> 		listeners += nfs_svc_create("mountd", MOUNTPROG,
>>>> 					MOUNTVERS, mount_dispatch, port);
>>>>
>>> Question, since unregister_services() only unregisters version
>>> that are currently requested, won't it miss unregistering 
>>> version that are not currently requested, ones that are left over
>>> from a previous instant of mountd? 
>>>
>>> The point being all versions need to be unregistered at his point, 
>>> not just the ones currently being requested. 
> 
> I actually don't see a case where you would want to unregister just specific versions.  unregister_services() is currently too clever, by half.
> 
> The best thing to do is have unregister_services unregister everything, unconditionally.  So, add the new unregister_services() call site as my patch does, but change unregister_services() itself to do something like:
> 
> 	nfs_svc_unregister(MOUNTPROG, MOUNTVERS);
> 	nfs_svc_unregister(MOUNTPROG, MOUNTVERS_POSIX);
> 	nfs_svc_unregister(MOUNTPROG, NFSV3);
> 
> What do you think?
This seems to work.. I'll just make the change can do the commit...

steved.
