From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 05 Dec 2008 14:12:27 -0500
Message-ID: <49397D1B.3000701@RedHat.com>
References: <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown> <20081205035803.GC15115@fieldses.org> <49392C14.7000709@RedHat.com> <20081205163824.GA29227@fieldses.org> <20081205172913.GB29227@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49883 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbYLETOs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 14:14:48 -0500
In-Reply-To: <20081205172913.GB29227@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Dec 05, 2008 at 11:38:24AM -0500, bfields wrote:
>> On Fri, Dec 05, 2008 at 08:26:44AM -0500, Steve Dickson wrote:
>>> J. Bruce Fields wrote:
>>>>> I think it would still be valuable to replace the 'sync' with two
>>>>> 'fsync's, one of the file, one on the directory.
>>>> Sure, may as well.--b.
>>>>
>>> Something similar to this:
>>>
>>> diff -up nfs-utils/utils/statd/sm-notify.c.orig nfs-utils/utils/statd/sm-notify.c
>>> --- nfs-utils/utils/statd/sm-notify.c.orig	2008-11-17 15:06:13.000000000 -0500
>>> +++ nfs-utils/utils/statd/sm-notify.c	2008-12-05 08:21:52.000000000 -0500
>>> @@ -211,12 +211,6 @@ usage:		fprintf(stderr,
>>>  	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
>>>  	get_hosts(_SM_BAK_PATH);
>>>  
>>> -	/* If there are not hosts to notify, just exit */
>>> -	if (!hosts) {
>>> -		nsm_log(LOG_DEBUG, "No hosts to notify; exiting");
>>> -		return 0;
>>> -	}
>> This was still a huge boot-time win in the common case, so now that
>> we've committed to it I'd rather not regress.  Let's just skip the
>> sync()s/fsncy()s in the !hosts case--that looks to me like the simplest
>> correct solution for now.
> 
> My argument for correctness: if we don't sync in that case, then on
> reboot the rename that updates the state will either have happened or
> (if a crash comes too soon) not.
> 
> It is OK for that update to not happen as long as we're assured it
> happens before the first lock request is made or replied to, or the
> first monitor request completes, as, in the absence of any notifies,
> those are the only points at which the new state will be exposed to the
> outside world.
Doesn't the sync() have to happen before the file is first
read by stated. Meaning before statd:main() calls load_state_number()?

> 
> The first lock request will also require an upcall to statd.  So we're
> OK as long as any monitor requests (from either the local kernel or
> remote peers) do a sync.
> 
> And statd should be doing a sync before responding to any monitor
> request.  As long as the SM_DIR is on the same filesystem as the state
> file, that would do the job....  But now that I look, I see statd is
> using an open with O_SYNC to ensure the new statd record hits stable
> storage.  Which we can't count on being enough.
> 
> How about adding an explicit fsync() of the state file (and parent
> directory) to statd's first succesful creation of a statd record,
> together with a comment explaining this?  So around about line 194 in
> utils/statd/monitor.c:sm_mon_1_svc()?
If we do the sync()/fsync() here we will also have to update MY_STATE
since that's what is the number used in the RPCs. But also I think
doing the sync this late be a bit waste since there is real good
chance the rename has already been sync-ed out by previous sync()
during boot up... or am I missing something... 

steved.

