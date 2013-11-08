Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757527Ab3KHQas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 11:30:48 -0500
Message-ID: <527D11F0.3040506@RedHat.com>
Date: Fri, 08 Nov 2013 11:31:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com>		 <1383852380.12966.5.camel@leira.trondhjem.org>		 <527C0548.1090205@RedHat.com>	 <1383860381.12966.37.camel@leira.trondhjem.org>	 <527C0CB6.8090308@RedHat.com> <1383863394.12966.63.camel@leira.trondhjem.org> <527CD765.1000903@RedHat.com> <EDB1FCDB-A6B6-4595-A46F-B73AF9FAA990@netapp.com> <527CFE57.9030106@RedHat.com> <C0AAACC4-B692-4B2B-91D3-6953E4A99B61@netapp.com>
In-Reply-To: <C0AAACC4-B692-4B2B-91D3-6953E4A99B61@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/11/13 10:16, Myklebust, Trond wrote:
> 
> On Nov 8, 2013, at 10:08, Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 08/11/13 09:30, Myklebust, Trond wrote:
>>>
>>> On Nov 8, 2013, at 7:21, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 07/11/13 17:29, Myklebust, Trond wrote:
>>>>>> Again, what servers, today, support this type of secure state establishment?
>>>>>>> Having this type of security in the client I think is good... but if
>>>>>>> the client is not talking with any servers that support this type 
>>>>>>> of security, why not have a way to turn it off?
>>>>> I don't understand. Servers are _required_ to support RPCSEC_GSS with
>>>>> krb5 by both RFC3530 and RFC5661. AUTH_SYS is, in fact, the optional
>>>>> flavour.
>>>> Agreed... 100% of the NFSv4 server have to support RPCSEC_GSS. its mandated
>>>> by the spec(s). 
>>>>
>>>>>
>>>>> The problem here is that sometimes kerberos isn't configured by the
>>>>> admin, who then expects that it shouldn't be necessary to run rpc.gssd
>>>>> or rpc.svcgssd. It is necessary because we first try the
>>>>> mandatory-to-implement and secure RPCSEC_GSS/krb5i flavour before
>>>>> falling back to the less secure AUTH_SYS...
>>>> Sometimes? Its generally not.. from my experience... 
>>>>
>>>> Basically how I interpret this last paragraph, is we will be requiring 
>>>> admins set up secure mounts for them to avoid the 15sec delay mount
>>>> times... aka... running a daemon that will say "no, no there is no 
>>>> security here" while spewing of log messages when Kerberos is not setup...
>>>
>>> No. All we are requiring is that they run rpc.gssd.
>> Even when they do not want any secure mounts at all?
>>
>> What is that justification?
> 
> They get to skip a 15 second wait without having to blacklist the krb5 module.
> 
> So, this is what I mean when I say that we _might_ need a mount option to 
> specify the security flavour that the client uses for the lease. It solves the 
> problem that Bruce mentioned about what to do when krb5i fails, and it allows admins 
> to not have to run rpc.gssd or blacklist any modules.
Fine... Would mind doing a brain dump of what this mount might look like
and how it work in a different thread... Since this is pretty beaten down
at this point... ;-) 

steved.

> 
> Trond
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
