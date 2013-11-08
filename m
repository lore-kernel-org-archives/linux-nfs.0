Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab3KHMU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 07:20:59 -0500
Message-ID: <527CD765.1000903@RedHat.com>
Date: Fri, 08 Nov 2013 07:21:57 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>		 <1383852380.12966.5.camel@leira.trondhjem.org>		 <527C0548.1090205@RedHat.com>	 <1383860381.12966.37.camel@leira.trondhjem.org>	 <527C0CB6.8090308@RedHat.com> <1383863394.12966.63.camel@leira.trondhjem.org>
In-Reply-To: <1383863394.12966.63.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/11/13 17:29, Myklebust, Trond wrote:
>> Again, what servers, today, support this type of secure state establishment?
>> > Having this type of security in the client I think is good... but if
>> > the client is not talking with any servers that support this type 
>> > of security, why not have a way to turn it off?
> I don't understand. Servers are _required_ to support RPCSEC_GSS with
> krb5 by both RFC3530 and RFC5661. AUTH_SYS is, in fact, the optional
> flavour.
Agreed... 100% of the NFSv4 server have to support RPCSEC_GSS. its mandated
by the spec(s). 

> 
> The problem here is that sometimes kerberos isn't configured by the
> admin, who then expects that it shouldn't be necessary to run rpc.gssd
> or rpc.svcgssd. It is necessary because we first try the
> mandatory-to-implement and secure RPCSEC_GSS/krb5i flavour before
> falling back to the less secure AUTH_SYS...
Sometimes? Its generally not.. from my experience... 

Basically how I interpret this last paragraph, is we will be requiring 
admins set up secure mounts for them to avoid the 15sec delay mount
times... aka... running a daemon that will say "no, no there is no 
security here" while spewing of log messages when Kerberos is not setup...

> 
>>>>>>> > >>> > > I think we should rather looks at adding a new mount option for
>>>>>>> > >>> > > specifying the security flavour to use when establishing basic NFSv4.x
>>>>>>> > >>> > > state, and then perhaps specifying the _default_ for that mount option
>>>>>>> > >>> > > using a module parameter.
>>>>> > >> > The problem is everything is hard code in these two areas so having
>>>>> > >> > a mount option would not work... 
>>> > > We can change that code.
>>> > > 
>>>>> > >> > The fact that -o sec=sys does not turn off the use of AUTH_GSS_KRB5x 
>>>>> > >> > is simple wrong... IMHO...
>>> > > I beg to differ. The problem previously was that it _did_ set the policy
>>> > > for the state management, and that meant that if you has 2 mounts on the
>>> > > same server with different security flavours, then then client behaviour
>>> > > depended on the order of the mounts. Get the order wrong, and you get
>>> > > anything from outright errors (CLID_IN_USE) to insecure behaviour.
>> > I see your point... but requiring all mounts to use some form 
>> > of security I don't think is the answer either... 
> I'm saying that we may need a way to specify the security flavour to be
> used by the client's state manager when establishing the NFSv4 lease,
> and that would need to be done on a per-server basis.
Yes! I agree... But we also have to have away turn off secure lease 
establishments when the server does support such technology.

I'm not saying we don't need this type of technology, I'm saying
we need a better to manage it. Having this module parameter is
away to manage it. 

steved.
