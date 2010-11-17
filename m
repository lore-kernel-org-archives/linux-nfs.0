Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933782Ab0KQPSp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Nov 2010 10:18:45 -0500
Message-ID: <4CE3F249.8050301@RedHat.com>
Date: Wed, 17 Nov 2010 10:18:33 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jim Rees <rees@umich.edu>, Valentijn Sessink <valentyn@blub.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Strange rpc.svcgssd behavior
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com> <4CE2AA3B.6070302@openoffice.nl> <4CE2DF2D.9070603@blub.net> <20101116201753.GB4482@merit.edu> <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com> <20101116205436.GA4595@merit.edu> <44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com>
In-Reply-To: <44C0977F-DBD6-4F87-B3A5-B2B66C784312@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry for the delayed response... I had my
head down for last couple of days... 

On 11/16/2010 04:42 PM, Chuck Lever wrote:
> 
> On Nov 16, 2010, at 3:54 PM, Jim Rees wrote:
> 
>> Chuck Lever wrote:
>>
>>  Before we go too far down the NM path of no return, I was under the
>>  impression that some applications require the host's name on the localhost
>>  entries in /etc/hosts.  That's why NM puts it there.
>>
>>  There's nothing invalid about having a hostname on the localhost entries
>>  in /etc/hosts, is there?
>>
>>  So I wonder if removing NM is really the solution here.
>>
>> No, it's not.  I just like to complain about NM.
>>
>> The original problem was that rpc.svcgssd couldn't figure out the correct
>> kerberos realm.  The fix in this particular case, I think, is to set the
>> realm explicitly in /etc/idmapd.conf.
> 
> It's having trouble determining the NFS server's hostname.  It needs to find the right nfs/your.host key in /etc/krb5.keytab.
> 
> I don't know if realm self-discovery is an issue too.
I think the problem is a reverse lookup is done on hostname that 
is found in the /etc/krb5.keytab. Instead of the FQDN being
returned, localhost is returned because the FQDN was added to 
the localhost line in /etc/hosts.

Actually I didn't realize it was NM doing that... I thought
it was the installer... 

steved.

