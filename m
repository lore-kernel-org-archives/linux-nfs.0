Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802Ab2DVEQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Apr 2012 00:16:43 -0400
Message-ID: <4F938620.2080301@redhat.com>
Date: Sun, 22 Apr 2012 09:46:32 +0530
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, malahal@us.ibm.com,
        bfields@fieldses.org, trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <1334749927-26138-1-git-send-email-jlayton@redhat.com> <20120420104055.511e15bc@tlielax.poochiereds.net>
In-Reply-To: <20120420104055.511e15bc@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/20/2012 08:10 PM, Jeff Layton wrote:
> On Wed, 18 Apr 2012 07:52:07 -0400
> Jeff Layton<jlayton@redhat.com>  wrote:
>
>> ESTALE errors are a source of pain for many users of NFS. Usually they
>> occur when a file is removed from the server after a successful lookup
>> against it.
>>
>> Luckily, the remedy in these cases is usually simple. We should just
>> redo the lookup, forcing revalidations all the way in and then retry the
>> call. We of course cannot do this for syscalls that do not involve a
>> path, but for path-based syscalls we can and should attempt to recover
>> from an ESTALE.
>>
>> This patch implements this by having the VFS reattempt the lookup (with
>> LOOKUP_REVAL set) and call exactly once when it would ordinarily return
>> ESTALE. This should catch the bulk of these cases under normal usage,
>> without unduly inconveniencing other filesystems that return ESTALE on
>> path-based syscalls.
>>
>> Note that it's possible to hit this race more than once, but a single
>> retry should catch the bulk of these cases under normal circumstances.
>>
>> This patch is just an example. We'll alter most path-based syscalls in a
>> similar fashion to fix this correctly. At this point, I'm just trying to
>> ensure that the retry semantics are acceptable before I being that work.
>>
>> Does anyone have strong objections to this patch? I'm aware that the
>> retry mechanism is not as robust as many (e.g. Peter) would like, but it
>> should at least improve the current situation.
>>
>> If no one has a strong objection, then I'll start going through and
>> adding similar code to the other syscalls. And we can hopefully we can
>> get at least some of them in for 3.5.
>>
>> Signed-off-by: Jeff Layton<jlayton@redhat.com>
>> ---
>>   fs/stat.c |    9 ++++++++-
>>   1 files changed, 8 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/stat.c b/fs/stat.c
>> index c733dc5..0ee9cb4 100644
>> --- a/fs/stat.c
>> +++ b/fs/stat.c
>> @@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
>>   {
>>   	struct path path;
>>   	int error = -EINVAL;
>> -	int lookup_flags = 0;
>> +	bool retried = false;
>> +	unsigned int lookup_flags = 0;
>>
>>   	if ((flag&  ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
>>   		      AT_EMPTY_PATH)) != 0)
>> @@ -84,12 +85,18 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
>>   	if (flag&  AT_EMPTY_PATH)
>>   		lookup_flags |= LOOKUP_EMPTY;
>>
>> +retry:
>>   	error = user_path_at(dfd, filename, lookup_flags,&path);
>>   	if (error)
>>   		goto out;
>>
>>   	error = vfs_getattr(path.mnt, path.dentry, stat);
>>   	path_put(&path);
>> +	if (error == -ESTALE&&  !retried) {
>> +		retried = true;
>> +		lookup_flags |= LOOKUP_REVAL;
>> +		goto retry;
>> +	}
>>   out:
>>   	return error;
>>   }
> Apologies for replying to myself here. Just to beat on the deceased
> equine a little longer, I should note that the above approach does
> *not* fix Peter's reproducer in his original email. It fails rather
> quickly when run simultaneously on the client and server.
>
> At least one of the tests in it creates and removes a hierarchy of
> directories in a loop. During that, the lookup from the client can
> easily fail more than once with ESTALE. Since we give up after a single
> retry, that causes the call to return ESTALE.
>
> While testing this approach with mkdir and fstatat, I modified the
> patch to retry multiple times, also retry when the lookup thows ESTALE
> and to throw a printk when the number of retries was>  1 with the
> number of retries that the call did and the eventual error code.
>
> With Peter's (admittedly synthetic) test, we can get an answer of sorts
> to Trond's question from earlier in the thread as to how many retries
> is "enough":
>
> [   45.023665] sys_mkdirat: retries=33 error=-2
> [   47.889300] sys_mkdirat: retries=51 error=-2
> [   49.172746] sys_mkdirat: retries=27 error=-2
> [   52.325723] sys_mkdirat: retries=10 error=-2
> [   58.082576] sys_mkdirat: retries=33 error=-2
> [   59.810461] sys_mkdirat: retries=5 error=-2
> [   63.387914] sys_mkdirat: retries=14 error=-2
> [   63.630785] sys_mkdirat: retries=4 error=-2
> [   68.268903] sys_mkdirat: retries=6 error=-2
> [   71.124173] sys_mkdirat: retries=99 error=-2
> [   75.657649] sys_mkdirat: retries=123 error=-2
> [   76.903814] sys_mkdirat: retries=26 error=-2
> [   82.009463] sys_mkdirat: retries=30 error=-2
> [   84.807731] sys_mkdirat: retries=67 error=-2
> [   89.825529] sys_mkdirat: retries=166 error=-2
> [   91.599104] sys_mkdirat: retries=8 error=-2
> [   95.621855] sys_mkdirat: retries=44 error=-2
> [   98.164588] sys_mkdirat: retries=61 error=-2
> [   99.783347] sys_mkdirat: retries=11 error=-2
> [  105.593980] sys_mkdirat: retries=104 error=-2
> [  110.348861] sys_mkdirat: retries=8 error=-2
> [  112.087966] sys_mkdirat: retries=46 error=-2
> [  117.613316] sys_mkdirat: retries=90 error=-2
> [  120.117550] sys_mkdirat: retries=2 error=-2
> [  122.624330] sys_mkdirat: retries=15 error=-2
>
> So, now I'm having buyers remorse of sorts about proposing to just
> retry once as that may not be strong enough to fix some of the cases
> we're interested in.
>
> I guess the questions at this point is:
>
> 1) How representative is Peter's mkdir_test() of a real-world workload?
>
> 2) if we assume that it is fairly representative of one, how can we
> achieve retrying indefinitely with NFS, or at least some large finite
> amount?
>
> I have my doubts as to whether it would really be as big a problem for
> other filesystems as Miklos and others have asserted, but I'll take
> their word for it at the moment. What's the best way to contain this
> behavior to just those filesystems that want to retry indefinitely when
> they get an ESTALE? Would we need to go with an entirely new
> ESTALERETRY after all?
>

Maybe we should have a default of a single loop and a tunable to allow clients 
to crank it up?

Ric

