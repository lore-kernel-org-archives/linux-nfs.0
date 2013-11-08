Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1204 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757324Ab3KHOaj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 09:30:39 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Date: Fri, 8 Nov 2013 14:30:37 +0000
Message-ID: <EDB1FCDB-A6B6-4595-A46F-B73AF9FAA990@netapp.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
		 <1383852380.12966.5.camel@leira.trondhjem.org>
		 <527C0548.1090205@RedHat.com>
	 <1383860381.12966.37.camel@leira.trondhjem.org>
	 <527C0CB6.8090308@RedHat.com>
 <1383863394.12966.63.camel@leira.trondhjem.org> <527CD765.1000903@RedHat.com>
In-Reply-To: <527CD765.1000903@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 8, 2013, at 7:21, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 07/11/13 17:29, Myklebust, Trond wrote:
>>> Again, what servers, today, support this type of secure state establishment?
>>>> Having this type of security in the client I think is good... but if
>>>> the client is not talking with any servers that support this type 
>>>> of security, why not have a way to turn it off?
>> I don't understand. Servers are _required_ to support RPCSEC_GSS with
>> krb5 by both RFC3530 and RFC5661. AUTH_SYS is, in fact, the optional
>> flavour.
> Agreed... 100% of the NFSv4 server have to support RPCSEC_GSS. its mandated
> by the spec(s). 
> 
>> 
>> The problem here is that sometimes kerberos isn't configured by the
>> admin, who then expects that it shouldn't be necessary to run rpc.gssd
>> or rpc.svcgssd. It is necessary because we first try the
>> mandatory-to-implement and secure RPCSEC_GSS/krb5i flavour before
>> falling back to the less secure AUTH_SYS...
> Sometimes? Its generally not.. from my experience... 
> 
> Basically how I interpret this last paragraph, is we will be requiring 
> admins set up secure mounts for them to avoid the 15sec delay mount
> times... aka... running a daemon that will say "no, no there is no 
> security here" while spewing of log messages when Kerberos is not setup...

No. All we are requiring is that they run rpc.gssd.

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

