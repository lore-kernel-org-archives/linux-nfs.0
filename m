From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Fri, 18 Jul 2008 08:46:55 +1000
Message-ID: <18559.52191.42583.685790@notabene.brown>
References: <18556.16890.235207.711721@notabene.brown>
	<76bd70e30807150831l294c7f0as8ba53709e71d5827@mail.gmail.com>
	<487E416A.4050007@RedHat.com>
	<18558.45412.19541.657376@notabene.brown>
	<487F1F1B.5080803@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:60045 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbYGQWq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 18:46:57 -0400
In-Reply-To: message from Steve Dickson on Thursday July 17
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday July 17, SteveD@redhat.com wrote:
> > 
> >> @@ -349,7 +364,6 @@ notify_host(int sock, struct nsm_host *host)
		struct addrinfo *hold = host->ai;
		struct addrinfo **next = &host->ai;
		*next = hold->ai_next;
> >>  		while ( *next )
> >>  			next = & (*next)->ai_next;
> >>  		*next = hold;
> >> -		hold->ai_next = NULL;
> >>  		memcpy(&host->addr, hold->ai_addr, hold->ai_addrlen);
> >>  		addr_set_port(&host->addr, 0);
> >>  		host->retries = 0;
> > 
> > which I think is wrong, and wondering why:
> After the while loop doesn't hold point to the head of the list?
> If so, setting hold->ai_next = NULL; orphans the rest of the list, right?
> Or am I missing something... 
> 
> steved.
>   

After the while loop, hold points to the original head of the list.
However the new head of this list was put in place by
        *next = hold->ai_next;

as next == &host->ai, the above line is equivalent to

        host->ai = host->ai->ai_next;

which clearly move the head pointer to the second entry.
hold->ai_next also points to this new head, so we have to clear it
(hold->ai = NULL) when we attach it to the end of the list
(*next = hold;, after the while loop).

NeilBrown
