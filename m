From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 02 May 2008 18:33:52 -0400
Message-ID: <481B96D0.8010802@gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>	 <20080418203225.GD28277@fieldses.org>	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>	 <20080421000214.GA5453@fieldses.org>	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>	 <481B316E.8090800@gmail.com> <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756245AbYEBWbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 18:31:43 -0400
In-Reply-To: <24c1515f0805021413u450d8bbcr806a90c327b287a1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Janne Karhunen wrote:
> On Fri, May 2, 2008 at 11:21 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>
>   
>>  After browsing thru "statd -n" flow, it is still not clear what will happen
>> if there are more than 2 interfaces used to export NFS shares ?
>>     
>
> How come? It will use the interface specified with -n.
>   

ok, just read your follow-on email .. so we can cross out this one.

>
>   
>>  Using "statd -H", together with patches described in:
>>  https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html ,
>>     
>
> So this basically makes it a users problem, I don't
> like it. Statd's standard notifications are just fine and
> I don't want to have anything to do with the process.
> It should work as is, out of the box, without writing
> separate programs to handle stuff that statd doesn't
> do.
>   
I think you mis-understand our approach. With our patch, you do *not* 
need to do anything if you have only one single (floating) interface to 
do nfs export (and you can have the machine configured to use other 
hostname). The statd's "my_name" is correctly filled (from kernel by our 
patch) - it is no longer bound to 127.0.0.1.

Maybe I mislead you in previous post. The "-H" is only an "example" - to 
show people how to selectively move an ip address around without 
affecting other co-existing nfs ip interface on the same server. I did 
plan to submit a complete user mode patch so the program after "-H" will 
have a default executable (but user still can use their own if they 
don't like our nlm directory structure).

>
>   
>>  our cluster failover (with 4 IP interfaces per server) seemed to run well
>> without troubles.
>>     
>
> Your idea was to serve traffic via all of these interfaces?
>   

yes ...

> One specific segment is just enough for us. 

I know .. but there *are* users and live systems *today* that have 
multiple nfs interfaces. For big-fat server, I normally saw 4.

> Our servers
> can have anything from 5 - 100 floating addresses and
> it would be just great if we could keep each service
> bound in it's own address. It's just better that way.
>
> To me these use cases are clearly different. You're
> trying to serve traffic to multiple segments and need
> stuff that 'user have to worry about' to accomplish
> this.  -n works as is for just one segment. And how
> many users really need interface specific selective
> grace anyway?
>
>
>   
I hope above clears the confusion ? Again, admin(s)  do *not* need to do 
anything if there is only one single (floating) nfs export IP address.

On the other hand,  we did see systems had many nfs interfaces (I was 
surprised too). And that was exactly the rationale to kick off this work 
three years ago . 

-- Wendy

