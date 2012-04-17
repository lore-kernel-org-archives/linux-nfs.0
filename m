Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795Ab2DQOPS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 10:15:18 -0400
Message-ID: <4F8D7ADF.9030709@RedHat.com>
Date: Tue, 17 Apr 2012 10:14:55 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr
 call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <20120413150518.GA1987@us.ibm.com> <20120413114236.0e557e01@tlielax.poochiereds.net> <4F8B1B7B.3040304@itwm.fraunhofer.de> <20120416073655.7cdb90cf@corrin.poochiereds.net> <4F8C3036.2030702@itwm.fraunhofer.de> <20120416134642.1754cd3e@corrin.poochiereds.net> <1334604785.2879.23.camel@lade.trondhjem.org> <20120416154322.0d95e435@corrin.poochiereds.net> <1334607906.2879.36.camel@lade.trondhjem.org> <20120416190548.2463d1d0@corrin.poochiereds.net> <4F8D580B.7060104@RedHat.com> <20120417093643.7f172057@corrin.poochiereds.net>
In-Reply-To: <20120417093643.7f172057@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/17/2012 09:36 AM, Jeff Layton wrote:
> On Tue, 17 Apr 2012 07:46:19 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 04/16/2012 07:05 PM, Jeff Layton wrote:
>>> On Mon, 16 Apr 2012 20:25:06 +0000
>>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>
>>>> On Mon, 2012-04-16 at 15:43 -0400, Jeff Layton wrote:
>>>>> On Mon, 16 Apr 2012 19:33:05 +0000
>>>>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>>>
>>>>>> On Mon, 2012-04-16 at 13:46 -0400, Jeff Layton wrote:
>>>>>>> The question about looping indefinitely really comes down to:
>>>>>>>
>>>>>>> 1) is a persistent ESTALE in conjunction with a successful lookup a
>>>>>>> situation that we expect to be temporary. i.e. will the admin at some
>>>>>>> point be able to do something about it? If not, then there's no point
>>>>>>> in continuing to retry. Again, this is a situation that *really* should
>>>>>>> not happen if the filesystem is doing the right thing.
>>>>>>>
>>>>>>> 2) If the admin can't do anything about it, is it reasonable to expect
>>>>>>> that users can send a fatal signal to hung applications if this
>>>>>>> situation occurs.
>>>>>>>
>>>>>>> We expect that that's ok in other situations to resolve hung
>>>>>>> applications, so I'm not sure I understand why it wouldn't be
>>>>>>> acceptable here...
>>>>>>
>>>>>> There are definitely potentially persistent pathological situations that
>>>>>> the filesystem can't do anything about. If the point of origin for your
>>>>>> pathname (for instance your current directory in the case of a relative
>>>>>> pathname) is stale, then no amount of looping is going to help you to
>>>>>> recover.
>>>>>>
>>>>>
>>>>> Ok -- Peter pretty much said something similar. Retrying indefnitely
>>>>> when the lookup returns ESTALE probably won't help. I'm ok with
>>>>> basically letting the VFS continue to do what it does there already. If
>>>>> it gets an ESTALE, it tries again with LOOKUP_REVAL set and then gives
>>>>> up if that doesn't work.
>>>>>
>>>>> If however, the operation itself keeps returning ESTALE, are we OK to
>>>>> retry indefinitely assuming that we'll break out of the loop on fatal
>>>>> signals?
>>>>>
>>>>> For example, something like the v2 patch I sent a little while ago?
>>>>
>>>>
>>>> Won't something like fstatat(AT_FDCWD, "", &stat, AT_EMPTY_PATH) risk
>>>> looping forever there, or am I missing something?
>>>>
>>>
>>> To make sure I understand, that should be "shortcut" for a lookup of the
>>> cwd?
>>>
>>> So I guess the concern is that you'd do the above and get a successful
>>> lookup since you're just going to get back the cwd. At that point,
>>> you'd attempt the getattr and get ESTALE back. Then, you'd redo the
>>> lookup with LOOKUP_REVAL set -- but since we're operating on the
>>> cwd, we don't have a way to redo the lookup since we don't have a
>>> pathname that we can look up again...
>>>
>>> So yeah, I guess if you're sitting in a stale directory, something like
>>> that could loop eternally.
>>>
>>> Do you think the proposed check for fatal_signal_pending is enough to
>>> mitigate such a problem? Or do we need to limit the number of retries
>>> to address those sorts of loops?
>>>
>> I think your version 2 patch is definitely more clever than v1, but I'm
>> thinking Trond's point is no matter what type of looping is done or how
>> long its done its going to fail... So why loop at all? 
>>
> 
> Because we can't distinguish between that case and a case where
> retrying may help. If we can avoid failing altogether, isn't that
> preferable?
> 
>> Again I think the safest and simply way, from the VFS point of view,
>> is do the looping once if the file system as registered for it
>> through the fs_flags. This will catch %99 of the issues, failing
>> on the %1 of the corner cases... 
>>
> 
> If we're just going to retry once, then I see no need to bother with a
> fs flag. Retrying once should be harmless for all filesystems. The main
> reason to bother with a per-fs flag is to deal with those that would
> have problems looping indefinitely on an ESTALE return from the
> operation.
True, but even so... Giving file systems an opt-out option with the 
default being out, maybe still have some merit... Making file systems
enable this new type of functionality would cut down on any of the
"surprise" that might occur with this redo ;-) 
 
> 
> So, to give your proposal some "legs", you'd prefer to see something
> like this?
> 
> ---------------------------------[snip]-------------------------------
> 
> [PATCH] vfs: make fstatat retry once on ESTALE errors from getattr call
> 
> A third patch. This one takes the minimalist approach. It only retries
> once per syscall.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/stat.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/stat.c b/fs/stat.c
> index c733dc5..0ee9cb4 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
>  {
>  	struct path path;
>  	int error = -EINVAL;
> -	int lookup_flags = 0;
> +	bool retried = false;
> +	unsigned int lookup_flags = 0;
>  
>  	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
>  		      AT_EMPTY_PATH)) != 0)
> @@ -84,12 +85,18 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
>  	if (flag & AT_EMPTY_PATH)
>  		lookup_flags |= LOOKUP_EMPTY;
>  
> +retry:
>  	error = user_path_at(dfd, filename, lookup_flags, &path);
>  	if (error)
>  		goto out;
>  
>  	error = vfs_getattr(path.mnt, path.dentry, stat);
>  	path_put(&path);
> +	if (error == -ESTALE && !retried) {
> +		retried = true;
> +		lookup_flags |= LOOKUP_REVAL;
> +		goto retry;
> +	}
>  out:
>  	return error;
>  }
Yes, with the exception of the fs_flag check. If this proves out to
handle 99% of the cases... all but the very few corner cases.. then
why does it have to be more complicated? 

steved.

