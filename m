From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle	massive	number
	of requests
Date: Wed, 16 Apr 2008 09:45:10 -0400
Message-ID: <E9FA280C-E881-4DCB-9C4C-5DBD4B16A984@oracle.com>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<1208234913.17169.50.camel@trinity.ogc.int>
	<20080415151227.GB32218@fieldses.org>
	<1208313790.3521.32.camel@trinity.ogc.int>
	<20080416025848.GA27274@fieldses.org>
	<1208316166.3521.42.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60267 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbYDPNqR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 09:46:17 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jm7xm-0005eC-EM
	for linux-nfs@vger.kernel.org; Wed, 16 Apr 2008 23:46:14 +1000
In-Reply-To: <1208316166.3521.42.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 15, 2008, at 11:22 PM, Tom Tucker wrote:
> On Tue, 2008-04-15 at 22:58 -0400, J. Bruce Fields wrote:
>> On Tue, Apr 15, 2008 at 09:43:10PM -0500, Tom Tucker wrote:
>>>
>>> On Tue, 2008-04-15 at 11:12 -0400, J. Bruce Fields wrote:
>>>> On Mon, Apr 14, 2008 at 11:48:33PM -0500, Tom Tucker wrote:
>>>>>
>>>>> Maybe this this is a TCP_BACKLOG issue?
>>>>
>>>> So, looking around.... There seems to be a global limit in
>>>> /proc/sys/net/ipv4/tcp_max_syn_backlog (default 1024?); might be  
>>>> worth
>>>> seeing what happens if that's increased, e.g., with
>>>>
>>>> 	echo 2048 >/proc/sys/net/ipv4/tcp_max_syn_backlog
>>>
>>> I think this represents the collective total for all listening
>>> endpoints. I think we're only talking about mountd.
>>
>> Yes.
>>
>>> Shooting from the hip...
>>>
>>> My gray haired recollection is that the single connection default  
>>> is a
>>> backlog of 10 (SYN received, not accepted connections). Additional  
>>> SYN's
>>> received to this endpoint will be dropped...clients will retry the  
>>> SYN
>>> as part of normal TCP retransmit...
>>>
>>> It might be that the CLOSE_WAIT's in the log are _normal_. That  
>>> is, they
>>> reflect completed mount requests that are in the normal close  
>>> path. If
>>> they never go away, then that's not normal. Is this the case?
>>
>> What he said was:
>>
>> 	"those fall over after some time and stay in CLOSE_WAIT state
>> 	until I restart the nfs-kernel-server."
>>
>> Carsten, are you positive that the same sockets were in CLOSE_WAIT  
>> the
>> whole time you were watching?  And how long was it before you gave up
>> and restarted?
>>
>>> Suppose the 10 is roughly correct. The remaining "jilted" clients  
>>> will
>>> retransmit their SYN after a randomized exponential backoff. I  
>>> think you
>>> can imagine that trying 1300+ connections of which only 10 succeed  
>>> and
>>> then retrying 1300-10 based on a randomized exponential backoff  
>>> might
>>> get you some pretty bad performance.
>>
>> Right, could be, but:
>>
>> ...
>>>> Oh, but: Grepping the glibc rpc code, it looks like it calls  
>>>> listen with
>>>> second argument SOMAXCONN == 128.  You can confirm that by  
>>>> strace'ing
>>>> rpc.mountd -F and looking for the listen call.
>>>>
>>>> And that socket's shared between all the mountd processes, so I  
>>>> guess
>>>> that's the real limit.  I don't see an easy way to adjust that.   
>>>> You'd
>>>> also need to increase /proc/sys/net/core/somaxconn first.
>>>>
>>>> But none of this explains why we'd see connections stuck in  
>>>> CLOSE_WAIT
>>>> indefinitely?
>>
>> So the limit appears to be more like 128, and (based on my quick  
>> look at
>> the code) that appears to baked in to the glibc rpc code.
>>
>> Maybe you could code around that in mountd.  Looks like the relevant
>> code is in nfs-utils/support/include/rpcmisc.c:rpc_init().
>
> If you really need to start 1300 mounts all at once then something  
> needs
> to change. BTW even after you get past mountd, the server is going to
> get pounded with SYN and RPC_NOP.

Would it be worth trying UDP, just as an experiment?

Force UDP for the mountd protocol by specifying the "mountproto=udp"  
option.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

