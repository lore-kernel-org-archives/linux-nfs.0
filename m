Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab3KGV4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 16:56:14 -0500
Message-ID: <527C0CB6.8090308@RedHat.com>
Date: Thu, 07 Nov 2013 16:57:10 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>	 <1383852380.12966.5.camel@leira.trondhjem.org>	 <527C0548.1090205@RedHat.com> <1383860381.12966.37.camel@leira.trondhjem.org>
In-Reply-To: <1383860381.12966.37.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/11/13 16:39, Myklebust, Trond wrote:
>> If we blacklist those module(s) then we are disabling secure mounts
>> > altogether... 
> What's the difference? If you use secure mounts, you really do want the
> NFSv4 state to be secure too.
Maybe I'm missing something via my testing.. It seems only the establishment
of the state is insecure not the actual transactions using that state.
So there is a window... but... 

Again, what servers, today, support this type of secure state establishment?
Having this type of security in the client I think is good... but if
the client is not talking with any servers that support this type 
of security, why not have a way to turn it off?

> 
>>> > > I think we should rather looks at adding a new mount option for
>>> > > specifying the security flavour to use when establishing basic NFSv4.x
>>> > > state, and then perhaps specifying the _default_ for that mount option
>>> > > using a module parameter.
>> > The problem is everything is hard code in these two areas so having
>> > a mount option would not work... 
> We can change that code.
> 
>> > The fact that -o sec=sys does not turn off the use of AUTH_GSS_KRB5x 
>> > is simple wrong... IMHO...
> I beg to differ. The problem previously was that it _did_ set the policy
> for the state management, and that meant that if you has 2 mounts on the
> same server with different security flavours, then then client behaviour
> depended on the order of the mounts. Get the order wrong, and you get
> anything from outright errors (CLID_IN_USE) to insecure behaviour.
I see your point... but requiring all mounts to use some form 
of security I don't think is the answer either... 

> 
>> >  Not having way to override this behavior
>> > is not a good thing... again... IMHO... 
>> > 
>> > Finally, Are there any servers out there today that support this type
>> > of behavior? Requiring secure state establishment or secure 
>> > pseudoroot lookups. 
>> > 
>> > Bruce, can we configure the Linux server to require this type security behavior? 
>> > Can any server out there require these type of security behavior?  
>> > 
>> > If the answer is no, then we really need a way to disable this type
>> > of behavior....
> I don't disagree with the goal, I disagree with the method.
I don't understand what you mean here... I did I say something right??? 8-) 

steved.
