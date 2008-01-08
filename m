From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Tue, 08 Jan 2008 10:52:19 -0500
Message-ID: <47839C33.6020207@redhat.com>
References: <1199534542-3384-1-git-send-email-jlayton@redhat.com>	<1199534542-3384-2-git-send-email-jlayton@redhat.com>	<1199534542-3384-3-git-send-email-jlayton@redhat.com>	<1199534542-3384-4-git-send-email-jlayton@redhat.com>	<1199534542-3384-5-git-send-email-jlayton@redhat.com>	<1199534542-3384-6-git-send-email-jlayton@redhat.com>	<1199534542-3384-7-git-send-email-jlayton@redhat.com>	<18307.7241.831689.998668@notabene.brown> <20080108082603.089718fc@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Neil Brown <neilb@suse.de>, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbYAHPzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 10:55:43 -0500
In-Reply-To: <20080108082603.089718fc-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
>
>> The previous patch removes a kill_proc(... SIGKILL),  this one adds it
>> back.
>> That makes me wonder if the intermediate state is 'correct'.
>>
>> But I also wonder what "correct" means.
>> Do we want all locks to be dropped when the last nfsd thread dies?
>> The answer is presumably either "yes" or "no".
>> If "yes", then we don't have that because if there are any NFS mounts
>> active, lockd will not be killed.
>> If "no", then we don't want this kill_proc here.
>>
>> The comment in lockd() which currently reads:
>>
>> 	/*
>> 	 * The main request loop. We don't terminate until the last
>> 	 * NFS mount or NFS daemon has gone away, and we've been sent
>> a
>> 	 * signal, or else another process has taken over our job.
>> 	 */
>>
>> suggests that someone once thought that lockd could hang around after
>> all nfsd threads and nfs mounts had gone, but I don't think it does.
>>
>> We really should think this through and get it right, because if lockd
>> ever drops it's locks, then we really need to make sure sm_notify gets
>> run.  So it needs to be a well defined event.
>>
>> Thoughts?
>>
>>     
>
> This is the part I've been struggling with the most -- defining what
> proper behavior should be when lockd is restarted. As you point out,
> restarting lockd without doing a sm_notify could be bad news for data
> integrity.
>
> Then again, we'd like someone to be able to shut down the NFS "service"
> and be able to unmount underlying filesystems without jumping through
> special hoops....
>
> Overall, I think I'd vote "yes". We need to drop locks when the last
> nfsd goes down. If userspace brings down nfsd, then it's userspace's
> responsibility to make sure that a sm_notify is sent when nfsd and lockd
> are restarted.
>   

I would vote for "no", at least for nfs v3. Shutting down lockd would 
require clients to reclaim the locks. With current status (protocol, 
design, and even the implementation itself, etc), it is simply too 
disruptive. I understand current logic (i.e. shutting down nfsd but 
leaving lockd alone) is awkward but debugging multiple platforms 
(remember clients may not be on linux boxes) is very non-trivial.

-- Wendy


