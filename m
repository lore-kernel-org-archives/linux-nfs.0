Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab1LNP4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 10:56:47 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEFuk39027431
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 10:56:46 -0500
Message-ID: <4EE8C73E.2050207@RedHat.com>
Date: Wed, 14 Dec 2011 10:56:46 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] clstated: reattempt the pipe open if it fails on
 ENOENT
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>	<1323871032-3191-3-git-send-email-jlayton@redhat.com>	<4EE8BC10.3010005@RedHat.com>	<20111214101927.551e3883@tlielax.poochiereds.net>	<4EE8C0ED.6090302@RedHat.com> <20111214103718.267b32fc@tlielax.poochiereds.net>
In-Reply-To: <20111214103718.267b32fc@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/14/2011 10:37 AM, Jeff Layton wrote:
> On Wed, 14 Dec 2011 10:29:49 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 12/14/2011 10:19 AM, Jeff Layton wrote:
>>> On Wed, 14 Dec 2011 10:09:04 -0500
>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 12/14/2011 08:57 AM, Jeff Layton wrote:
>>>>> Generally, we want this daemon started before nfsd starts. Deal with the
>>>>> situation where the pipe hasn't shown up yet.
>>>> This can be done with your systemd start up script. Plus I'm not sure its 
>>>> a good idea to steal cpu cycles waiting for an event that may never happen...
>>>>
>>>
>>> Presumably you just wouldn't start the daemon if you have no intent to
>>> use it.
>>>
>>> It does sleep 1s between each check, so the time is fairly minimal,
>>> but I'm definitely open to doing this differently. What may be
>>> reasonable is adding code to the daemon to check and see if the
>>> v4recoverydir is present. If it is, then just exit. Otherwise, wait for
>>> the pipe to show up.
>> Why just let the systemd scrips worry about the order of when to start
>> things up... To be honest, that is one thing systemd does do fairly well.
>>
> 
> Because not everyone uses systemd, and we have to deal with the
> "legacy" case too for the transition phase.
> 
> It's generally preferable not to start up nfsd until everything it
> needs is up. If we do what you suggest, then we're basically mandating
> that this daemon can't start until nfsd is up and running.
Order has ways been a part of how and when things are started which
have always been handled by initscripts. That's their job, to start
things in the correct order. 

I understand you want to make the daemon bullet proof... but starting
things up in the wrong order is an error... IMHO... 

> 
> Could you give some details on how you think this ought to work?
> 
I would think a error message stating unable to open whatever and then 
say something like please make sure the nfs server is up and running,
would work... It seems to me this is a pretty common way of handling 
this type of situation.... although I can not come up with a 
explicit example, atm. 

steved.
 
