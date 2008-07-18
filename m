From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Fri, 18 Jul 2008 00:41:28 -0400
Message-ID: <76bd70e30807172141p49952efdl20660f817548cbf6@mail.gmail.com>
References: <18556.16890.235207.711721@notabene.brown>
	 <76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
	 <487E416A.4050007@RedHat.com>
	 <18558.45412.19541.657376@notabene.brown>
	 <76bd70e30807170809ya493100x7330f61d55bb12a3@mail.gmail.com>
	 <18559.52918.675492.673560@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:60425 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYGREld (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2008 00:41:33 -0400
Received: by ug-out-1314.google.com with SMTP id h2so15857ugf.16
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2008 21:41:29 -0700 (PDT)
In-Reply-To: <18559.52918.675492.673560-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 17, 2008 at 6:59 PM, Neil Brown <neilb@suse.de> wrote:
> On Thursday July 17, chucklever@gmail.com wrote:
>> > What the code is doing is taking the first addrinfo from the host->ai
>> > list, and moving it to the end - effectively rotating the list.
>> > This shouldn't change what freeaddrinfo will do.
>> >
>> > One of us is missing something.
>>
>> Even after staring at this for half an hour last week, it looked to me
>> like you were chopping off the last addrinfo in the list each time
>> through the "retries" loop.  I could hope for something a little more
>> straightforward to do the address rotation.
>
> I assume from your use of the past-tense (looked) that you can see how
> it works now?

Yes, and...

> I guess you could argue that it has been over-optimised, and that
> something like:
>
>                struct addrinfo *first = host->ai;
>                struct addrinfo **next = &host->ai;
>
>                /* remove the first entry from the list */
>                host->ai = first->ai_next;
>                first->ai_next = NULL;
>                /* find the end of the list */
>                next = &host->ai;
>                while ( *next )
>                        next = & (*next)->ai_next;
>                /* put first entry at end */
>                *next = first;
>                memcpy(&host->addr, first->ai_addr, first->ai_addrlen);
>                addr_set_port(&host->addr, 0);
>                host->retries = 0;
>
> might be a little clearer?

Yes.  Though I'm still a little leary of "next = & (*next)->ai_next;".
 I think that's the part that confused me initially.  Considering we
all have tens or hundreds of KLOC to look after, I like the little
details to be butt-simple.  (I said "butt." ;-)

I guess my preferred solution would be to house an extra pointer in
host-> that simply referred to the addrinfo struct of current
interest.  Re-arranging linked lists is somewhat expensive and
error-prone, but this is not a performance path, so no big deal.

It would also be slightly more bullet-proof to repeat the
host_lookup() call after you've rotated through all the existing
addresses, rather than simply forcing a rebind periodically.  Probably
not worth the trouble, but it _would_ be possible now that you have
moved the host_lookup() call into the background part of sm-notify.

Note that getaddrinfo(3) will always try to return the most useful
address in the first addrinfo struct (required by Internet standard,
it turns out).  It's worth trying the other addresses, but the first
one will likely produce the correct results.

Furthermore, I don't think the current logic adequately handles the
case where a hostname might resolve to multiple unique hosts (like a
round-robin load-balancing arrangement).  Do you consider this a
common or even a probable case, out of curiousity?

>> It would be nice to consolidate the acquisition and freeing of the
>> addrinfo structs for each host so the lifetime of the results is made
>> clear.  Moving the host_lookup() into notify_host() does help with
>> that.
>>
>> There is another addrinfo leak in notify(), I think.  In the "Bind
>> source IP if provided on command line" paragraph, host_lookup() is
>> called and the address is copied, but that list of addrinfo structs is
>> never freed, is it?
>
> Yes, that is theoretically a leak, though as it is only called once in
> a program with a limited lifetime it isn't a serious leak.

Yes, I agree.  I just like to be tidy.  Tidiness implies that it's
more likely all the various failure modes have been properly addressed
(perhaps I'm fooling myself).  Seeing these little leaks makes me
think the code may have other problems, but that's just the strange
obsessive/compulsive person that I am.

> The reality with this program, is that it:
>   allocated lots of data structures
>   processes them and frees them
>   exits
>
> as the exit will implicitly free everything, all the other calls to
> free allocated memory are fairly moot.  But I would have no objection
> to putting a freeaddrinfo call into that part of notify().

-- 
Chuck Lever
