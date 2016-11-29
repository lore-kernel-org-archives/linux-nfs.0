Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34166 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755365AbcK2XFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 18:05:30 -0500
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a
 permanent error
To: NeilBrown <neilb@suse.com>
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115640.26568.2934329194247787636.stgit@noble>
 <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com>
 <87bmx7cezt.fsf@notabene.neil.brown.name>
 <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com>
 <87poll93s7.fsf@notabene.neil.brown.name>
 <214253e5-5ef2-ae9a-bc57-20ed1c2f7e3a@RedHat.com>
 <87a8ci7yuo.fsf@notabene.neil.brown.name>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <db46b103-b5ac-998e-7bb6-8138f6a12711@RedHat.com>
Date: Tue, 29 Nov 2016 18:05:27 -0500
MIME-Version: 1.0
In-Reply-To: <87a8ci7yuo.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/29/2016 04:36 PM, NeilBrown wrote:
> On Tue, Nov 29 2016, Steve Dickson wrote:
> 
>> My apologies for the delayed response... I just saw this... 
> 
> 
> Yeah, life happens.
> 
>>
>> On 11/23/2016 06:26 PM, NeilBrown wrote:
>>> On Thu, Nov 24 2016, Steve Dickson wrote:
>>>>>
>>>>> So I think the current behavior is correct.  You might be able to argue
>>>>> that certain error codes should trigger a shorter timeout, but it would
>>>>> need a strong argument.
>>>> Going with the theory the window is very small, how about 
>>>> a retry with a timeout then a failure? 
>>>
>>> I started looking at changing the timeout and it wouldn't be too hard
>>> (if we can agree on a suitable delay), but I feel I must ask why this is
>>> important.
>> Over the last few Connectathon and bakeathons I've been
>> floating the idea of dismantling the UDP support and
>> nobody to objected... The main reason is to cut the testing 
>> matrix in half.
> 
> Dismantling?  As in: removing the code?  I wouldn't like that.
No. Basically not to use the code. 

> Certainly switch the default and even pop up a warning "UDP bad - use
> TCP ok?".
Right... the first step on the client would be stop 
negotiating UDP mounts but still allow mount -o udp,v3 
to work, but not hang for 2.5 minutes before failing.

Then, I guess, not to have all the other daemons 
not to advertise UDP unless configured to do so,
but off by default. 

> 
>>
>> I keep getting these goofy UDP bugs from our QE guys that
>> nobody is going to fix... and I have not seen a UDP bug
>> from a customer in years.. I really don't think 
>> it being used so why continue to support it?
> 
> Completely happy for distros to choose not to support it.  But there are
> more users of Linux than we distro people hear from.
Fair enough... So leave the code in, but off by default
so it's not something that has to be tested. 

> 
>>
>>> In what situation are you likely to mount with the wrong protocol, that
>>> you aren't able to just Ctrl-C when you realized what a dumb thing you
>>> just did?
>> I turned off the UDP support in rpc.nfsd and mounts started to hang.
> 
> Mounts that would otherwise fail - correct?
> Exactly the same behavior as if you disabled NFS service on the server.
Yes, fail immediately which happen before commit df0b9998

> 
> I have difficulty seeing this as being a serious problem.  It gets
> notices, someone does "s/udp/tcp/" on /etc/fstab.  Problem gone.
I have not looked, but will it hang the reboot for a few minutes?

>>> If rpcbind isn't running, which is arguably a very similar situation
>>> (no protocols are register) we have always had a long timeout. Why is
>>> "just one protocol not registered" any different?
>> ECONNREFUSED can also me the server is not up so we 
>> need to wait.
> 
> If there servers in not up you get EHOSTUNREACHABLE (or however it is
> spelled) or a timeout.
> We need to wait on RPC_PROGNOTREGISTERED for exactly the same reason
> that we need to wait for ECONNREFUSED: the server might still be coming
> up and hasn't quite got everything registered properly yet.
Well when the server is down I'm seeing 
"mount.nfs: mount(2): Connection refused" on the v4 mount then mounts
then "RPC: Program not registered" on both the TCP and UDP v3 mounts.
And that cycles through for 2.5 mins until the failure.

So you are correct, there is no difference between when a server
is down and when a protocol is not supported. But this is where
we differ. A server could come up but a protocol is not all of
a sudden be supported. I think we should handle that case better. 
 
> 
>>
>>>
>>>
>>> Anyway, below is the patch I was working on.  I stopped when I wasn't
>>> sure how to handle ECONNREFUSED.
>> I've quick took and it does look a little messy or we
>> revert the EOPNOTSUPP commit...
> 
> The EOPNOTSUPP commit fixed a real bug.  The bug would result in a mount
> attempt failing when it should succeed.  Reverting that is not an
> option.
So the bug was that fact rpcbind was not up but the NFS server was?
Or both were on there way up?

> Your symptom is not so much a bug and an inconvenience.  You issue a
> command that will fail, and it takes a bit longer to fail than you would
> like.  You still get the correct end result.
No, I see it as a regression as how we used to handle a 
protocol not being supported.

> 
> I don't think the patch is messy ... or at least, the resulting code
> isn't.
> I'll have another go and submit a proper patch.
Thank you... I'm confident things will work out well.

steved.

> 
> Thanks,
> NeilBrown
> 
>>
>> But at least you know my motivation.
>>
>> steved. 
>>>
>>> NeilBrown
>>>
>>>
>>>
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index d5dfb5e4a669..084776115b9>>> I disagree with the "hang forever" description.  I just tested after
>>>>> disabling UDP on an nfs server, and the delay was 2 minutes, 5 seconds
>>>>> before a failure was reported.  It might be longer when trying TCP on a
>>>>> server that only supports UDP.
>>>> Yeah I did not wait that long... You are much more of a patient man than I ;-) 
>>>> I do think this is a regression. Going an from an instant failure to one
>>>> that takes over 2min is not a good thing... IMHO.
>>>> f 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -935,24 +935,30 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>>>   * failed so far, but fail immediately if there is a local
>>>   * error (like a bad mount option).
>>>   *
>>> - * ESTALE is also a temporary error because some servers
>>> - * return ESTALE when a share is temporarily offline.
>>> + * If there is a remote error, like ESTALE or RPC_PROGNOTREGISTERED
>>> + * then it is probably permanent, but there is a small chance
>>> + * the it is temporary can we caught the server at an awkward
>>> + * time during start-up.  A shorter timeout is best for such
>>> + * circumstances, so return a distinct status.
>>>   *
>>> - * Returns 1 if we should fail immediately, or 0 if we
>>> - * should retry.
>>> + * Returns PERMANENT if we should fail immediately,
>>> + * TEMPORARY if we should retry normally, or
>>> + * REMOTE if we should retry with shorter timeout.
>>>   */
>>> -static int nfs_is_permanent_error(int error)
>>> +enum error_type { PERMANENT, TEMPORARY, REMOTE };
>>> +static enum error_type nfs_error_type(int error)
>>>  {
>>>  	switch (error) {
>>>  	case ESTALE:
>>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>>> +		return REMOTE;
>>>  	case ETIMEDOUT:
>>>  	case ECONNREFUSED:
>>>  	case EHOSTUNREACH:
>>> -	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>>>  	case EAGAIN:
>>> -		return 0;	/* temporary */
>>> +		return TEMPORARY;
>>>  	default:
>>> -		return 1;	/* permanent */
>>> +		return PERMANENT;
>>>  	}
>>>  }
>>>  
>>> @@ -967,6 +973,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>>  {
>>>  	unsigned int secs = 1;
>>>  	time_t timeout;
>>> +	int last_errno = 0;
>>>  
>>>  	timeout = nfs_parse_retry_option(mi->options,
>>>  					 NFS_DEF_FG_TIMEOUT_MINUTES);
>>> @@ -987,13 +994,22 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>>>  			 */
>>>  			return EX_SUCCESS;
>>>  
>>> -		if (nfs_is_permanent_error(errno))
>>> +		switch(nfs_error_type(errno)) {
>>> +		case PERMANENT:
>>> +			timeout = 0;
>>>  			break;
>>> -
>>> -		if (time(NULL) > timeout) {
>>> +		case REMOTE:
>>> +			if (errno == last_errno)
>>> +				timeout = 0;
>>> +			break;
>>> +		case TEMPORARY:
>>>  			errno = ETIMEDOUT;
>>>  			break;
>>>  		}
>>> +		last_errno = errno;
>>> +
>>> +		if (time(NULL) > timeout)
>>> +			break;
>>>  
>>>  		if (errno != ETIMEDOUT) {
>>>  			if (sleep(secs))
>>> @@ -1020,7 +1036,7 @@ static int nfsmount_parent(struct nfsmount_info *mi)
>>>  	if (nfs_try_mount(mi))
>>>  		return EX_SUCCESS;
>>>  
>>> -	if (nfs_is_permanent_error(errno)) {
>>> +	if (nfs_error_type(errno) == PERMANENT) {
>>>  		mount_error(mi->spec, mi->node, errno);
>>>  		return EX_FAIL;
>>>  	}
>>> @@ -1055,8 +1071,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
>>>  		if (nfs_try_mount(mi))
>>>  			return EX_SUCCESS;
>>>  
>>> -		if (nfs_is_permanent_error(errno))
>>> +		switch (nfs_error_type(errno)) {
>>> +		case REMOTE: /* Doesn't hurt to keep trying remote errors
>>> +			      * when in the background
>>> +			      */
>>> +		case PERMANENT:
>>> +			timeout = 0;
>>>  			break;
>>> +		}
>>>  
>>>  		if (time(NULL) > timeout)
>>>  			break;
>>>
