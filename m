Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:57314 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697AbcGHQ3B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 12:29:01 -0400
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of EPERM
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1467994665.27907.28.camel@poochiereds.net>
Date: Fri, 8 Jul 2016 12:28:54 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <D77C6D53-8852-45E9-8EA1-3C3617925816@linuxhacker.ru>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru> <1467975747.24149.16.camel@poochiereds.net> <05872587-E1A0-4714-AF43-7070D72D930C@linuxhacker.ru> <1467993208.27907.17.camel@poochiereds.net> <9F6401BF-9F1A-4D6C-BE36-BE2064EC9BF3@linuxhacker.ru> <1467994665.27907.28.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 8, 2016, at 12:17 PM, Jeff Layton wrote:

> On Fri, 2016-07-08 at 11:59 -0400, Oleg Drokin wrote:
>> On Jul 8, 2016, at 11:53 AM, Jeff Layton wrote:
>> 
>>> On Fri, 2016-07-08 at 11:14 -0400, Oleg Drokin wrote:
>>>> On Jul 8, 2016, at 7:02 AM, Jeff Layton wrote:
>>>> 
>>>>> On Thu, 2016-07-07 at 21:47 -0400, Oleg Drokin wrote:
>>>>>> It looks like we are bit overzealous about failing mkdir/create/mknod
>>>>>> with permission denied if the parent dir is not writeable.
>>>>>> Need to make sure the name does not exist first, because we need to
>>>>>> return EEXIST in that case.
>>>>>> 
>>>>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>>>>> ---
>>>>>> A very similar problem exists with symlinks, but the patch is more
>>>>>> involved, so assuming this one is ok, I'll send a symlink one separately.
>>>>>>  fs/nfsd/nfs4proc.c |  6 +++++-
>>>>>>  fs/nfsd/vfs.c      | 11 ++++++++++-
>>>>>>  2 files changed, 15 insertions(+), 2 deletions(-)
>>>>>> 
>>>>> 
>>>>> 
>>>>> nit: subject says EPERM, but I think you mean EACCES. The mnemonic I've
>>>>> always used is that EPERM is "permanent". IOW, changing permissions
>>>>> won't ever allow the user to do something. For instance, unprivileged
>>>>> users can never chown a file, so they should get back EPERM there. When
>>>>> a directory isn't writeable on a create they should get EACCES since
>>>>> they could do the create if the directory were writeable.
>>>> 
>>>> Hm, I see, thanks.
>>>> Confusing that you get "Permission denied" from perror ;)
>>>> 
>>> 
>>> Yes indeed. It's a subtle and confusing distinction.
>>> 
>>>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>>>>> index de1ff1d..0067520 100644
>>>>>> --- a/fs/nfsd/nfs4proc.c
>>>>>> +++ b/fs/nfsd/nfs4proc.c
>>>>>> @@ -605,8 +605,12 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>>>>  
>>>>>>  	fh_init(&resfh, NFS4_FHSIZE);
>>>>>>  
>>>>>> +	/*
>>>>>> +	 * We just check thta parent is accessible here, nfsd_* do their
>>>>>> +	 * own access permission checks
>>>>>> +	 */
>>>>>>  	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
>>>>>> -			   NFSD_MAY_CREATE);
>>>>>> +			   NFSD_MAY_EXEC);
>>>>>>  	if (status)
>>>>>>  		return status;
>>>>>>  
>>>>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>>>>> index 6fbd81e..6a45ec6 100644
>>>>>> --- a/fs/nfsd/vfs.c
>>>>>> +++ b/fs/nfsd/vfs.c
>>>>>> @@ -1161,7 +1161,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>>>>>  	if (isdotent(fname, flen))
>>>>>>  		goto out;
>>>>>>  
>>>>>> -	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
>>>>>> +	/*
>>>>>> +	 * Even though it is a create, first we see if we are even allowed
>>>>>> +	 * to peek inside the parent
>>>>>> +	 */
>>>>>> +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
>>>>>>  	if (err)
>>>>>>  		goto out;
>>>>>>  
>>>>>> @@ -1211,6 +1215,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>>>>>  		goto out; 
>>>>>>  	}
>>>>>>  
>>>>>> +	/* Now let's see if we actually have permissions to create */
>>>>>> +	err = nfsd_permission(rqstp, fhp->fh_export, dentry, NFSD_MAY_CREATE);
>>>>>> +	if (err)
>>>>>> +		goto out;
>>>>>> +
>>>>>>  	if (!(iap->ia_valid & ATTR_MODE))
>>>>>>  		iap->ia_mode = 0;
>>>>>>  	iap->ia_mode = (iap->ia_mode & S_IALLUGO) | type;
>>>>> 
>>>>> 
>>>>> Ouch. This means two nfsd_permission calls per create operation. If
>>>>> it's necessary for correctness then so be it, but is it actually
>>>>> documented anywhere (POSIX perhaps?) that we must prefer EEXIST over
>>>>> EACCES in this situation?
>>>> 
>>>> Opengroup manpage: http://pubs.opengroup.org/onlinepubs/009695399/functions/mkdir.html
>>>> newer version is here:
>>>> http://pubs.opengroup.org/onlinepubs/9699919799/
>>>> 
>>>> They tell us that we absolutely must fail with EEXIST if the name is a symlink
>>>> (so we need to lookup it anyway), and also that EEXIST is the failure code
>>>> if the path exists.
>>>> 
>>> 
>>> I'm not sure that that verbiage supersedes the fact that you don't have
>>> write permissions on the directory. Does it?
>> 
>> "If path names a symbolic link, mkdir() shall fail and set errno to [EEXIST]."
>> 
>> This sounds pretty straightforward to me, no?
>> Since it does not matter that we do not have write permissions here, because
>> the name already exists.
>> 
>> (also there are tons of applications that make this assumption when
>> badly reimplementing their mkdir -p thing, I imagine they also have this same
>> reading of the man page - this is why I even care about it).
>> 
> 
> I always have trouble with this sort of thing. Just because it's in
> DESCRIPTION, does that make it supersede the part in ERRORS? IOW, I
> think that's just telling you how to handle a symlink as the last
> component, not that you have to do that before the permissions check.

Personally I think of it like open(O_CREAT).
If the file exists, you just open it even if you have no permissions to
add stuff in the parent.

Same with mkdir/mknod - if the name already exists - you don't need any
write rights to create it - it's already there.

symlink was likely just special cased to highlight that it should not
just be followed (unlike what happens with open).

Also VFS even goes to some pains to prioritize returning EEXIST over
other errors like EROFS and such (something nfs (both server and client?)/lustre
does not, but I suspect it's a lot more fringe case?).

> Now that said, as a practical matter I do agree that EEXIST _is_
> probably the more helpful error message. If there are applications that
> rely on this then we probably should just take your patch.
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>

