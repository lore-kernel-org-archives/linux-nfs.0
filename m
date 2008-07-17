From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Thu, 17 Jul 2008 06:29:47 -0400
Message-ID: <487F1F1B.5080803@RedHat.com>
References: <18556.16890.235207.711721@notabene.brown>	<76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>	<487E416A.4050007@RedHat.com> <18558.45412.19541.657376@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbYGQKaX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 06:30:23 -0400
In-Reply-To: <18558.45412.19541.657376-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> On Wednesday July 16, SteveD@redhat.com wrote:
>>> Arguably it would be cleaner architecturally if the DNS lookup were in
>>> notify_host().  Since doing it in notify() means you will be looking
>>> up these addresses on retries, maybe the host_lookup() call should be
>>> integrated into the "If we retransmitted 4 times" logic.  That would
>>> be an opportunity to fix the addrinfo leak in there.
> 
> What addrinfo leak is that?
See questions below...

> 
>>> [Note that freeaddrinfo(3) simply walks the list of addrinfo
>>> structures and frees them.  By setting ai_next to NULL in some of the
>>> addrinfo structures, sm-notify is orphaning them -- freeaddrinfo(3)
>>> will never find them].
>>>
> 
> I assume we are talking about the code in notify_host in the
>   if (host->retries >= 4) {
> branch.
> 
> What the code is doing is taking the first addrinfo from the host->ai
> list, and moving it to the end - effectively rotating the list.
> This shouldn't change what freeaddrinfo will do.
> 
> One of us is missing something.
>>
>> I believe the following patch address those minor comments... true?
> 
> Except for:
> 
>> @@ -349,7 +364,6 @@ notify_host(int sock, struct nsm_host *host)
>>  		while ( *next )
>>  			next = & (*next)->ai_next;
>>  		*next = hold;
>> -		hold->ai_next = NULL;
>>  		memcpy(&host->addr, hold->ai_addr, hold->ai_addrlen);
>>  		addr_set_port(&host->addr, 0);
>>  		host->retries = 0;
> 
> which I think is wrong, and wondering why:
After the while loop doesn't hold point to the head of the list?
If so, setting hold->ai_next = NULL; orphans the rest of the list, right?
Or am I missing something... 

steved.
  
