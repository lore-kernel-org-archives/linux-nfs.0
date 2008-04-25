From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: multiple instances of rpc.statd
Date: Fri, 25 Apr 2008 18:07:27 -0400
Message-ID: <20080425220727.GA9597@fieldses.org>
References: <200804251531.21035.bs@q-leap.de> <4811E0D7.4070608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38471 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932210AbYDYWHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 18:07:31 -0400
In-Reply-To: <4811E0D7.4070608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 09:47:03AM -0400, Wendy Cheng wrote:
> Bernd Schubert wrote:
>> Hello,
>>
>> on servers with heartbeat managed resources one rather often has the 
>> situation one exports different directories from different resources.
>>
>> It now may happen all resources are running on one host, but they can 
>> also run from different hosts. The situation gets even more complicated 
>> if the server is also a nfs client.
>>
>> In principle having different nfs resources works fine, only the statd 
>> state directory is a problem. Or in principle the statd concept at all. 
>> Actually we would need to have several instances of statd running using 
>> different directories. These then would have to be migrated from one 
>> server to the other on resource movement. However, as far I understand 
>> it, there does not even exist the basic concept for this, doesn't it? 
>>
>>   
> The efforts have been attempted (to remedy this issue) and a complete  
> set of patches have been (kept) submitting for the past two years. The   
> patch acceptance progress is very slow (I guess people just don't want  
> to get bothered with cluster issues ?).

We definitely want to get this all figured out....

> Anyway, the kernel side has the basic infrastructure to handle the  
> problem (it stores the incoming clients IP address as part of its  
> book-keeping record) - just a little bit tweak will do the job. However,  
> the user side statd directory needs to get re-structured. I didn't  
> publish the user side directory structure script during my last round of  
> submission. Forking statd into multiple threads do not solve all the  
> issues. Check out:
> https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html

So for basic v2/v3 failover, what remains is some statd -H scripts, and
some form of grace period control?  Is there anything else we're
missing?

--b.
