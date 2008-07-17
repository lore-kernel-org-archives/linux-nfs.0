From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Fri, 18 Jul 2008 08:59:02 +1000
Message-ID: <18559.52918.675492.673560@notabene.brown>
References: <18556.16890.235207.711721@notabene.brown>
	<76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
	<487E416A.4050007@RedHat.com>
	<18558.45412.19541.657376@notabene.brown>
	<76bd70e30807170809ya493100x7330f61d55bb12a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Chuck Lever" <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:60617 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486AbYGQW7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 18:59:04 -0400
In-Reply-To: message from Chuck Lever on Thursday July 17
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday July 17, chucklever@gmail.com wrote:
> > What the code is doing is taking the first addrinfo from the host->ai
> > list, and moving it to the end - effectively rotating the list.
> > This shouldn't change what freeaddrinfo will do.
> >
> > One of us is missing something.
> 
> Even after staring at this for half an hour last week, it looked to me
> like you were chopping off the last addrinfo in the list each time
> through the "retries" loop.  I could hope for something a little more
> straightforward to do the address rotation.

I assume from your use of the past-tense (looked) that you can see how
it works now?
I guess you could argue that it has been over-optimised, and that
something like:

		struct addrinfo *first = host->ai;
		struct addrinfo **next = &host->ai;

		/* remove the first entry from the list */
		host->ai = first->ai_next;
		first->ai_next = NULL;
		/* find the end of the list */
		next = &host->ai;
		while ( *next )
			next = & (*next)->ai_next;
		/* put first entry at end */
		*next = first;
		memcpy(&host->addr, first->ai_addr, first->ai_addrlen);
		addr_set_port(&host->addr, 0);
		host->retries = 0;

might be a little clearer?


> 
> It would be nice to consolidate the acquisition and freeing of the
> addrinfo structs for each host so the lifetime of the results is made
> clear.  Moving the host_lookup() into notify_host() does help with
> that.
> 
> There is another addrinfo leak in notify(), I think.  In the "Bind
> source IP if provided on command line" paragraph, host_lookup() is
> called and the address is copied, but that list of addrinfo structs is
> never freed, is it?

Yes, that is theoretically a leak, though as it is only called once in
a program with a limited lifetime it isn't a serious leak.

The reality with this program, is that it:
   allocated lots of data structures
   processes them and frees them
   exits

as the exit will implicitly free everything, all the other calls to
free allocated memory are fairly moot.  But I would have no objection
to putting a freeaddrinfo call into that part of notify().

NeilBrown
