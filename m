Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414Ab2E2Qtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 12:49:50 -0400
Message-ID: <4FC4FE05.5020708@RedHat.com>
Date: Tue, 29 May 2012 12:49:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Honor the no_root_squash flag on pseudo roots.
References: <1338296836-28243-1-git-send-email-steved@redhat.com>  <1338303611.5433.14.camel@lade.trondhjem.org> <4FC4F17E.90000@RedHat.com> <1338308959.5433.48.camel@lade.trondhjem.org>
In-Reply-To: <1338308959.5433.48.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/29/2012 12:29 PM, Myklebust, Trond wrote:
> On Tue, 2012-05-29 at 11:55 -0400, Steve Dickson wrote:
>>
>> On 05/29/2012 11:00 AM, Trond Myklebust wrote:
>>> On Tue, 2012-05-29 at 09:07 -0400, Steve Dickson wrote:
>>>> If root squashing is turned off on a export that
>>>> has multiple directories, the parent directories
>>>> of the pseudo exports that's built, also needs to
>>>> have root squashing turned off.
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>>  utils/mountd/v4root.c |    9 ++++++++-
>>>>  1 files changed, 8 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
>>>> index 708eb61..ad8a3e7 100644
>>>> --- a/utils/mountd/v4root.c
>>>> +++ b/utils/mountd/v4root.c
>>>> @@ -92,7 +92,14 @@ v4root_create(char *path, nfs_export *export)
>>>>  	exp = export_create(&eep, 0);
>>>>  	if (exp == NULL)
>>>>  		return NULL;
>>>> -	xlog(D_CALL, "v4root_create: path '%s'", exp->m_export.e_path);
>>>> +	/*
>>>> +	 * Honor the no_root_squash flag 
>>>> +	 */
>>>> +	if ((curexp->e_flags & NFSEXP_ROOTSQUASH) == 0)
>>>> +		exp->m_export.e_flags &= ~NFSEXP_ROOTSQUASH;
>>>> +	xlog(D_CALL, "v4root_create: path '%s' flags 0x%x", 
>>>> +		exp->m_export.e_path, exp->m_export.e_flags);
>>>> +
>>>>  	return &exp->m_export;
>>>>  }
>>>
>>>
>>> As long as the user is authenticated, why do we care whether or not they
>>> are squashed to user 'nobody' for authorisation purposes? There
>>> shouldn't be any permission checks enforced on the pseudo-root, should
>>> there?
>>>
>> The access checks come during the lookup of the pseudo-root. 
>>
>> For example
>>      /home/steved/work *(rw,no_root_squash)
>>
>> This is the  export which causes mountd builds the pseudo-roots of 
>>      '/', '/home', and '/home/steved'
>>
>> Now if the no_root_squash is not set on those pseudo-roots the
>> access bits returned by server will cause the lookup of
>> /home/steved/work to fail. 
> 
> If '/', '/home' and '/home/steved' aren't exported directories, then how
> can they have properties such as acls? 
They don't. '/', '/home' and '/home/steved' are not being exported. Only
/home/steved/work is being exported in the namespace. So /home/steved/work
can have properties such as acls, but the components in the path can't.

If you wanted those to those type of properties on the path components, 
you would have to explicitly export them.


> I thought the whole point of the
> pseudo-filesystem was to just provide a namespace that bridges between
> actual exported filesystems.
That's exactly what happens.... 

> As long as I'm authenticated (i.e. my RPC credential matches the 'sec='
> line in /etc/exports), then why shouldn't I be able to 'cd'
> into /home/steved and run an 'ls'?
And you can. But all you are going to see is the exported directory, in
this case 'work'. For example: say you mount '/' on /mnt and do an ls.
This would be the tree:

# ls /mnt
./  ../  home/
# ls /mnt/work/home
./  ../  steved/
# ls /mnt/work/home/steved
./  ../  work/

steved.
