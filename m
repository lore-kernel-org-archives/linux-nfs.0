From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Thu, 17 Jul 2008 11:09:31 -0400
Message-ID: <76bd70e30807170809ya493100x7330f61d55bb12a3@mail.gmail.com>
References: <18556.16890.235207.711721@notabene.brown>
	 <76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
	 <487E416A.4050007@RedHat.com>
	 <18558.45412.19541.657376@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:54320 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756952AbYGQPJd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2008 11:09:33 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1960564yxm.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2008 08:09:32 -0700 (PDT)
In-Reply-To: <18558.45412.19541.657376-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2008 at 10:41 PM, Neil Brown <neilb@suse.de> wrote:
> On Wednesday July 16, SteveD@redhat.com wrote:
>>
>> >
>> > Arguably it would be cleaner architecturally if the DNS lookup were in
>> > notify_host().  Since doing it in notify() means you will be looking
>> > up these addresses on retries, maybe the host_lookup() call should be
>> > integrated into the "If we retransmitted 4 times" logic.  That would
>> > be an opportunity to fix the addrinfo leak in there.
>
> What addrinfo leak is that?
>
>> >
>> > [Note that freeaddrinfo(3) simply walks the list of addrinfo
>> > structures and frees them.  By setting ai_next to NULL in some of the
>> > addrinfo structures, sm-notify is orphaning them -- freeaddrinfo(3)
>> > will never find them].
>> >
>
> I assume we are talking about the code in notify_host in the
>  if (host->retries >= 4) {
> branch.
>
> What the code is doing is taking the first addrinfo from the host->ai
> list, and moving it to the end - effectively rotating the list.
> This shouldn't change what freeaddrinfo will do.
>
> One of us is missing something.

Even after staring at this for half an hour last week, it looked to me
like you were chopping off the last addrinfo in the list each time
through the "retries" loop.  I could hope for something a little more
straightforward to do the address rotation.

It would be nice to consolidate the acquisition and freeing of the
addrinfo structs for each host so the lifetime of the results is made
clear.  Moving the host_lookup() into notify_host() does help with
that.

There is another addrinfo leak in notify(), I think.  In the "Bind
source IP if provided on command line" paragraph, host_lookup() is
called and the address is copied, but that list of addrinfo structs is
never freed, is it?

>> I believe the following patch address those minor comments... true?
>
> Except for:
>
>> @@ -349,7 +364,6 @@ notify_host(int sock, struct nsm_host *host)
>>               while ( *next )
>>                       next = & (*next)->ai_next;
>>               *next = hold;
>> -             hold->ai_next = NULL;
>>               memcpy(&host->addr, hold->ai_addr, hold->ai_addrlen);
>>               addr_set_port(&host->addr, 0);
>>               host->retries = 0;
>
> which I think is wrong, and wondering why:
>
>> @@ -394,7 +408,11 @@ notify_host(int sock, struct nsm_host *host)
>>       }
>>       len = (p - msgbuf) << 2;
>>
>> -     sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest));
>> +     if (sendto(sock, msgbuf, len, 0, (struct sockaddr *) &dest, sizeof(dest)) < 0)
>> +             nsm_log(LOG_WARNING, "Sending Reboot Notification to "
>> +                     "'%s' failed: errno %d (%s)", host->name, errno, strerror(errno));
>> +
>> +     return 0;
>>  }

Yes, it's good to check for a return code here; but I'm wondering why
change it in this patch?

>>
>>  /*
>
> Yes, I believe it addresses those comments.
>
> Acked-by: NeilBrown <neilb@suse.de>
>
> Thanks!
> NeilBrown

--
Chuck Lever
