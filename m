From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: multiple instances of rpc.statd
Date: Fri, 25 Apr 2008 11:39:15 -0400
Message-ID: <4811FB23.4010509@gmail.com>
References: <200804251531.21035.bs@q-leap.de> <4811E0D7.4070608@gmail.com> <200804251630.36917.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbYDYPhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 11:37:22 -0400
In-Reply-To: <200804251630.36917.bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bernd Schubert wrote:
> Hello Wendy.
>
> On Friday 25 April 2008 15:47:03 Wendy Cheng wrote:
>   
>> The efforts have been attempted (to remedy this issue) and a complete
>> set of patches have been (kept) submitting for the past two years. The
>> patch acceptance progress is very slow (I guess people just don't want
>> to get bothered with cluster issues ?).
>>     
>
> Well, I think people are just ignorant. I did see your discussions about NLM 
> in the past on the NFS mailing list, but actually I didn't understand the 
> entire point of discussion ;) I was simply used to active-passive services 
> (mostly due to heartbeat-1.x) and there we just had /var/lib/nfs linked to 
> the exported directory.
>
> After I started to work here, I was confronted with the fact we do have 
> working active-active clusters here, but nobody besides me ever cared about 
> the locking problem :( NFS failovers just are done ignoring file locks.
> Seems so far also nobody run into a problem, but maybe the result was so 
> obscure that nobody ever bothered to complain...
> I'm just afraid most admins will simply do like this...
>   

That's an accurate observation :) .. people are just ignorant until they 
get bitten by the problem. Then they blush out nasty words  about Linux 
servers and go for proprietary solutions.

There are amazing amount of "workaround"(s) and funny setup(s) to bypass 
various Linux problems. Admins normally don't care the details but just 
know if they do certain "tricks", things work. I was looking at a 
performance issue last week why clustered mail servers ran miserably 
slow. As a person who don't know much about mail server, I was surprised 
to learn it is a common practice that linux email servers could be 
configured to grab flock, followed by posix lock, then wrote a lock file 
whenever a "write" occurs - all three actions are used concurrently to 
protect one single file (?).  It was a very interesting conversation.

-- Wendy 

