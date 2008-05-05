From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 05 May 2008 11:21:36 -0400
Message-ID: <481F2600.20501@gmail.com>
References: <20080421000214.GA5453@fieldses.org>	 <20080429161607.GA20420@fieldses.org>	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>	 <481B316E.8090800@gmail.com>	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>	 <481B96D0.8010802@gmail.com>	 <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>	 <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com> <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2009 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486AbYEEPTY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:19:24 -0400
In-Reply-To: <24c1515f0805050801m66cce68k94073914ba26511e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Janne Karhunen wrote:
> On Mon, May 5, 2008 at 10:59 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>
>   
>>> In any case, if there's still a legimate use case for -n, even if it's
>>> not great, we should err on the side of fixing it just to save problems
>>> for anyone with an existing working setup.
>>>
>>>       
>>  Simpler code and consolidated logic flow are always better - would like to
>> vote for its deletion.
>>     
>
> So the solution would be to use -H with a script that
> does sm-notify with user specified name (-v)? Kernel
> name can't be used directly as it might migrate to
> node that has different name.
>
>
>   
No. "-H" is only for different export (server IP) interfaces. Say server 
has 10.1.1.1 and 10.1.1.2 as NFS export interfaces. If 10.1.1.1 is 
migrated but 10.1.1.2 stays, you would like to notify the nfs clients 
coming in from 10.1.1.1 but not the clients from 10.1.1.2, you need to 
structure your sm directory seperately. That is the usage of "-H" (to 
allow admin to organize client IPs).

For a single export IP interface like you have (even you have a seperate 
hostname), ignore "-H". I believe "sm-notify -v" should be enough - 
otherwise we have bugs - i.e., sm-notify should be part of your nfsd 
bring-up script.

-- Wendy

