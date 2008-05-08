From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH - nfs-utils] Make sure statd gets started when 'string options' are in use.
Date: Thu, 8 May 2008 10:56:26 -0400
Message-ID: <7E3DAF69-8554-46C5-B585-AFE03DAD9D45@oracle.com>
References: <18463.57567.260973.429439@notabene.brown> <F7A5F2B8-A400-425C-9D90-EAACC9E5F086@oracle.com> <18466.27122.507819.788772@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58332 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbYEHO5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2008 10:57:15 -0400
In-Reply-To: <18466.27122.507819.788772-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 7, 2008, at 10:48 PM, Neil Brown wrote:
> On Tuesday May 6, chuck.lever@oracle.com wrote:
>> On May 6, 2008, at 12:38 AM, Neil Brown wrote:
>>> The code for checking and starting statd was only in the binary-
>>> options
>>> branch of the code.
>>> This moves it into common code.
>>> ---
>>> utils/mount/mount.c    |   22 ++++++++++++++++++++--
>>> utils/mount/nfsmount.c |   11 -----------
>>> 2 files changed, 20 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
>>> index 5076468..0036caa 100644
>>> --- a/utils/mount/mount.c
>>> +++ b/utils/mount/mount.c
>>> @@ -334,7 +334,8 @@ static void parse_opt(const char *opt, int
>>> *mask, char *extra_opts, int len)
>>> * standard options (indicated by MS_ bits), and output parameter
>>> * "@extra_opts" gets all the filesystem-specific options.
>>> */
>>> -static void parse_opts(const char *options, int *flags, char
>>> **extra_opts)
>>> +static void parse_opts(const char *options, int *flags, char
>>> **extra_opts,
>>> +		       int *lock)
>>> {
>>> 	if (options != NULL) {
>>> 		char *opts = xstrdup(options);
>>> @@ -358,6 +359,10 @@ static void parse_opts(const char *options, int
>>> *flags, char **extra_opts)
>>> 			/* end of option item or last item */
>>> 			if (*p == '\0' || *(p + 1) == '\0') {
>>> 				parse_opt(opt, flags, *extra_opts, len);
>>> +				if (strcmp(opt, "lock") == 0)
>>> +					*lock = 1;
>>> +				if (strcmp(opt, "nolock") == 0)
>>> +					*lock = 0;
>>> 				opt = NULL;
>>> 			}
>>> 		}
>>> @@ -421,6 +426,7 @@ int main(int argc, char *argv[])
>>> 	char *spec, *mount_point, *fs_type = "nfs";
>>> 	char *extra_opts = NULL, *mount_opts = NULL;
>>> 	uid_t uid = getuid();
>>> +	int lock = 1;
>>>
>>> 	progname = basename(argv[0]);
>>>
>>> @@ -531,7 +537,7 @@ int main(int argc, char *argv[])
>>> 		goto out;
>>> 	}
>>>
>>> -	parse_opts(mount_opts, &flags, &extra_opts);
>>> +	parse_opts(mount_opts, &flags, &extra_opts, &lock);
>>>
>>> 	if (uid != 0) {
>>> 		if (!(flags & (MS_USERS|MS_USER))) {
>>> @@ -546,6 +552,18 @@ int main(int argc, char *argv[])
>>> 		goto out;
>>> 	}
>>>
>>> +	if (!fake && lock) {
>>> +		if (!start_statd()) {
>>> +			nfs_error(_("%s: rpc.statd is not running but is "
>>> +				"required for remote locking.\n"
>>> +				"   Either use '-o nolock' to keep "
>>> +				"locks local, or start statd."),
>>> +					progname);
>>> +			mnt_err = EX_FAIL;
>>> +			goto out;
>>> +		}
>>> +	}
>>> +
>>
>> You probably want to gate this based on NFS version (ie do the
>> checking only for NFSv2/v3 mounts, and not for NFSv4 mounts)
>
> Yes, of course :-(
> I remember think about that but must have forgotten when I actually
> cut the patch.
>
>>
>> There is already a function in stropts.c (called
>> set_mandatory_options) that might be a better place to put the  
>> special
>> option parsing, as you can use the nice po_* calls, and it already  
>> has
>> a switch for detecting which NFS version is being requested.
>
> I cannot bring myself to put code in a function called
> "set_mandatory_options" which does not, in fact, set any options,
> whether mandatory or not.

/me makes the Scooby noise... (or is it the Tim Allen noise?)

Huh?  set_mandatory_options sets up both "addr=" and "clientaddr=".   
Both of these are required by the kernel, thus they are mandatory  
options.  So I don't understand your objection.

That function is the designated place to do specific option  
processing, and even has a specific check for which type of file  
system is being mounted.  Your fix would be simpler (it would add less  
redundant logic) if it were added in set_mandatory_options().

It's easy enough to change the name of the function if you think that  
would help make it more clear.

>> Since the common part of this code (start_statd) is already in a
>> helper, I would leave the existing logic in nfsmount.c, and just  
>> add a
>> handful of lines in stropts.c:set_mandatory_options that worries  
>> about
>> "lock/nolock" for NFSv2/v3 mounts.
>
> So how about the following?
>
> Thanks for the feedback.
>
> NeilBrown
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index cdd610e..be77d17 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -694,6 +694,17 @@ int nfsmount_string(const char *spec, const  
> char *node, const char *type,
> 	if (!set_mandatory_options(type, &saddr, options))
> 		goto out;
>
> +	if (!fake && strcmp(type, "nfs4") != 0 &&
> +	    po_rightmost(options, "nolock", "lock") != PO_KEY1_RIGHTMOST)
> +		if (!start_statd()) {
> +			nfs_error(_("%s: rpc.statd is not running but is "
> +				    "required for remote locking.\n"
> +				    "   Either use '-o nolock' to keep "
> +				    "locks local, or start statd."),
> +				  progname);
> +			goto out;
> +		}
> +
> 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)
> 		retval = nfsmount_bg(spec, node, type, hostname, flags,
> 					options, fake, child, extra_opts);

That's much closer to what I was thinking of.  But again, this belongs  
in set_mandatory_options() (or whatever we want to call the function).

It may seem like I'm splitting hairs, but the whole point of  
nfsmount_string() is to split the incoming mount option string into an  
easy-to-parse data structure, then pass the data structure to helpers  
to do the actual work.  The nfsmount_string() function is meant to be  
free of logic that is specific to a file system type or specific to a  
particular mount option (even fg/bg should be moved to a helper... I  
think I will construct a patch to do that right now).

The point is to keep each of these functions simple; they should all  
operate at the same level of detail, and encapsulate just a few  
important decisions at that level.

nfsmount_string() is meant to be the "35,000 foot" entry point.  Other  
functions, like parse_devname(), are meant to handle simple string  
manipulation.  Combining dissimilar levels of detail is like a  
layering violation, and then over time we end up with unmaintainable  
logic such as today's nfsmount.c, which attempts to do nearly  
everything in a single giant function.

NFS mounting is so subtle and exception filled it is worth taking a  
few moments to factor this correctly.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
