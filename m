From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Tue, 27 May 2008 09:32:27 -0400
Message-ID: <RTPCLUEXC1-PRDqYW8B0000016d@RTPMVEXC1-PRD.hq.netapp.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
 <20080519144806.GB7622@fieldses.org>
 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
 <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
 <9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
 <20080526074054.141945a7@tleilax.poochiereds.net>
 <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.com> <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Jeff Layton" <jlayton@redhat.com>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758220AbYE0NcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 09:32:23 -0400
In-Reply-To: <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <20080519144806.GB7622@fieldses.org>
 <9e8c52a20805230744m2f7488e5q2867674f2987444-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <RTPCLUEXC1-PRDRXf2L00000168-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <9e8c52a20805260144u34f81996oa27475cc4c2e72d2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <20080526074054.141945a7-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
 <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 08:15 AM 5/27/2008, Alexander Borghgraef wrote:
>It varies. I've had occurrences where it lasted for 15mins, but recent
>ones have been too short to register.

When you say "lasted", do you mean the file with the problem starts to
work (i.e. shows attributes), or that it basically vanishes? I am thinking
that perhaps the client thinks the file exists, but the server disagrees.
If you have multiple mail servers and there's an application synchronization
issue, this could be the problem.

Also, are the clocks synchronized between your clients and the server?
Clock skew can make this kind of problem worse.

>> If so, it might be interesting to run:
>>
>>    strace stat cur
>>
>> ...and see what error it's returning.
>
>Ok, I'll do that when I get an error which lasts long enough.

And if it shows a hard error, please also turn on a few NFS client
debugging flags and capture the log:

	rpcdebug -m nfs -s dircache lookupcache
	stat cur
	dmesg >/tmp/send-this-log
	rpcdebug -m nfs -c dircache lookupcache

Tom.

