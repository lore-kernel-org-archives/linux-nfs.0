From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] libtirpc: handle large numbers of supplemental groups
 gracefully (try #2)
Date: Tue, 16 Feb 2010 15:10:02 -0500
Message-ID: <4B7AFB9A.1010208@oracle.com>
References: <1266347817-11186-1-git-send-email-jlayton@redhat.com>	<4B7AF0D9.4030208@redhat.com> <20100216143307.45a7ed42@tlielax.poochiereds.net> <4B7AF6CD.3080808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:26524 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab0BPUM1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Feb 2010 15:12:27 -0500
In-Reply-To: <4B7AF6CD.3080808@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/16/2010 02:49 PM, Peter Staubach wrote:
> Jeff Layton wrote:
>> On Tue, 16 Feb 2010 14:24:09 -0500
>> Peter Staubach<staubach@redhat.com>  wrote:
>>
>>> Jeff Layton wrote:
>>>> This is the second attempt at this patch. The main changes are that this
>>>> one doesn't set a floor value for the size of the group list. There are
>>>> also a few minor cleanups and comments added.
>>>>
>>>> If authunix_create_default() is called by a user with more than 16
>>>> supplimental groups, it'll abort(), which causes the program to crash
>>>> and coredump.
>>>>
>>>> Fix it to handle this situation gracefully. Get the number of groups
>>>> that the user has first, and then allocate a big enough buffer to hold
>>>> them. Then, just don't let the lower function use more than the NGRPS
>>>> groups.
>>>>
>>>> Also fix up the error handling in this function so that it just returns
>>>> a NULL pointer on error and logs a message via warnx() instead of
>>>> calling abort().
>>>>
>>>> Reported-by: Peter Engel<peter.engel-y6kNeMnOB+c@public.gmane.org>
>>>> Signed-off-by: Jeff Layton<jlayton@redhat.com>
>>>> ---
>>>>   src/auth_unix.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>>>>   1 files changed, 56 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/src/auth_unix.c b/src/auth_unix.c
>>>> index 71ca15d..a295e71 100644
>>>> --- a/src/auth_unix.c
>>>> +++ b/src/auth_unix.c
>>>> @@ -49,6 +49,7 @@
>>>>   #include<stdlib.h>
>>>>   #include<unistd.h>
>>>>   #include<string.h>
>>>> +#include<errno.h>
>>>>
>>>>   #include<rpc/types.h>
>>>>   #include<rpc/xdr.h>
>>>> @@ -175,20 +176,69 @@ AUTH *
>>>>   authunix_create_default()
>>>>   {
>>>>   	int len;
>>>> +	size_t bufsize = 0;
>>>>   	char machname[MAXHOSTNAMELEN + 1];
>>>>   	uid_t uid;
>>>>   	gid_t gid;
>>>> -	gid_t gids[NGRPS];
>>>> +	gid_t *gids = NULL;
>>>> +	AUTH *auth;
>>>> +
>>>> +	if (gethostname(machname, sizeof machname) == -1) {
>>>> +		warnx("%s: gethostname() failed: %s", __func__,
>>>> +			strerror(errno));
>>>> +		return NULL;
>>>> +	}
>>>>
>>>> -	if (gethostname(machname, sizeof machname) == -1)
>>>> -		abort();
>>>>   	machname[sizeof(machname) - 1] = 0;
>>>>   	uid = geteuid();
>>>>   	gid = getegid();
>>>> -	if ((len = getgroups(NGRPS, gids))<  0)
>>>> -		abort();
>>>> +
>>>> +retry:
>>>> +	len = getgroups(0, NULL);
>>>> +	if (len<  0) {
>>>> +		warnx("%s: failed to get number of groups: %s", __func__,
>>>> +			strerror(errno));
>>>> +		return NULL;
>>>> +	}
>>>> +
>>>> +	if (len == 0)
>>>> +		goto no_groups;
>>>> +
>>>> +	bufsize = len * sizeof(gid_t);
>>>> +	gids = mem_alloc(bufsize);
>>>> +	if (gids == NULL) {
>>>> +		warnx("%s: memory allocation failed: %s", __func__,
>>>> +			strerror(ENOMEM));
>>>> +		return NULL;
>>>> +	}
>>>> +
>>>> +	len = getgroups(len, gids);
>>>> +	if (len<  0) {
>>>> +		mem_free(gids, bufsize);
>>>> +		/*
>>>> +		 * glibc equivalent routines mention that it's possible for
>>>> +		 * the number of groups to change between two getgroups calls.
>>>> +		 * If that happens, retry the whole thing again.
>>>> +		 */
>>>> +		if (len == -EINVAL) {
>>>> +			gids = NULL;
>>>> +			bufsize = 0;
>>>> +			goto retry;
>>>> +		}
>>>> +		warnx("%s: failed to get group list: %s", __func__,
>>>> +			strerror(errno));
>>>> +		return NULL;
>>>> +	}
>>>> +
>>>> +	/* AUTH_UNIX has a hard limit of NGRPS supplemental groups */
>>>> +	if (len>  NGRPS)
>>>> +		len = NGRPS;
>>>> +
>>>> +no_groups:
>>>>   	/* XXX: interface problem; those should all have been unsigned */
>>>> -	return (authunix_create(machname, uid, gid, len, gids));
>>>> +	auth = authunix_create(machname, uid, gid, len, gids);
>>>> +	mem_free(gids, bufsize);
>>>> +	return auth;
>>>>   }
>>>>
>>>>   /*
>>> This change to restrict the groups used to the first NGRPS
>>> groups is one that we have always avoided.  It can be quite
>>> confusing to the user, to have an operation fail, but then
>>> to look and notice that the correct group is listed.
>>>
>>> Having the library abort seems odd and wrong, but this will
>>> also change semantics.  Is there really a problem here,
>>> after all of these years, that must be addressed?
>>>
>>
>> Yes, we had a bug report against nfs-utils where someone was seeing
>> umount.nfs core dump because root was in>NGRPS groups.
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=565507
>>
>> ...as Chuck points out, this is basically what glibc has done for
>> years. While it may be confusing for users, I think it's more
>> preferable than having the programs fail outright.
>>
>> What sort of behavior would you propose in its place?
>>
>
> Well, I do agree that a library routine should not call abort().
> That's just pure and simple, wrong.  That bug must be fixed.
>
> However, making a policy decision for the user also seems
> wrong.  Just because glibc did something does not make it right.

I'm not going to argue with that :-)

> It does tend to make it a standard, so the semantic change
> argument becomes weaker, but this change was made to a different
> RPC library, so the application must have/be changed to use it,
> so all bets are off again.

Not precisely true here.  authunix_create_default() is, I believe, also 
part of the legacy RPC interface (TS-RPC).  Thus any application that 
uses only the legacy RPC calls and is relinked with libtirpc can use 
this interface, and may expect it to behave as before.

> My inclination would be to return NULL and see who complains.

Yeah, unfortunately many of authunix_create_default's callers don't 
check the return value.

In the umount.nfs and showmount cases, what would be the appropriate 
recovery action for the application, if authunix_create_default() 
returns NULL?

-- 
chuck[dot]lever[at]oracle[dot]com
