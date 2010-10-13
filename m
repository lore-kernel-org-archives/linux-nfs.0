Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab0JMUjy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 16:39:54 -0400
Message-ID: <4CB61916.2010602@RedHat.com>
Date: Wed, 13 Oct 2010 16:39:50 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/15] mountd: Clear mountd registrations at start up
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000411.6667.17979.stgit@ellison.1015granger.net> <4CB5C876.3030203@RedHat.com> <4CB5CC64.1060303@RedHat.com> <B4BCB06D-A992-407C-BD96-65E7AE1F0649@oracle.com>
In-Reply-To: <B4BCB06D-A992-407C-BD96-65E7AE1F0649@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



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
Well I thinking we only time we should unconditionally unregister 
everything is during startup... since the rest of the time we
know which versions have been started... but either way if fine
by me... As long as rpcbind does not fill the system log with 
messages complaining about unregistering services that have
not be registered... but I find that out in my testing... 

steved.

