Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754785Ab3KGVYb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 16:24:31 -0500
Message-ID: <527C0548.1090205@RedHat.com>
Date: Thu, 07 Nov 2013 16:25:28 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <1383851364-8370-1-git-send-email-steved@redhat.com> <1383852380.12966.5.camel@leira.trondhjem.org>
In-Reply-To: <1383852380.12966.5.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 07/11/13 14:26, Myklebust, Trond wrote:
> On Thu, 2013-11-07 at 14:09 -0500, Steve Dickson wrote:
>> This new module parameter makes the v4 client
>> use the minimal authentication flavor (AUTH_UNIX)
>> when establishing NFSV4 state and doing the
>> pseudoroot lookup
>>
> 
> That looks very ad-hoc. Quite frankly, you can do the exact same thing
> already by simply blacklisting the rpcsec_gss_krb5 and/or auth_rpcgss
> modules.
I tried to keep a very small foot print... I'm not sure why that 
looks ad-hoc to you... 

If we blacklist those module(s) then we are disabling secure mounts
altogether... 

> 
> I think we should rather looks at adding a new mount option for
> specifying the security flavour to use when establishing basic NFSv4.x
> state, and then perhaps specifying the _default_ for that mount option
> using a module parameter.
The problem is everything is hard code in these two areas so having
a mount option would not work... 

The fact that -o sec=sys does not turn off the use of AUTH_GSS_KRB5x 
is simple wrong... IMHO... Not having way to override this behavior
is not a good thing... again... IMHO... 

Finally, Are there any servers out there today that support this type
of behavior? Requiring secure state establishment or secure 
pseudoroot lookups. 

Bruce, can we configure the Linux server to require this type security behavior? 
Can any server out there require these type of security behavior?  

If the answer is no, then we really need a way to disable this type
of behavior....

steved.
