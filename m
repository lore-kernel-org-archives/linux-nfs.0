Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbbG3S3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 14:29:15 -0400
Message-ID: <55BA6CF9.7080505@RedHat.com>
Date: Thu, 30 Jul 2015 14:29:13 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: managing the system's NFSv4 domain name
References: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com> <55BA2902.2020903@RedHat.com> <CF4DF6BD-CACC-4C75-98CF-DE5E26F10AE7@oracle.com>
In-Reply-To: <CF4DF6BD-CACC-4C75-98CF-DE5E26F10AE7@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck

On 07/30/2015 11:17 AM, Chuck Lever wrote:
>>> >> Does it make sense to extend the nfsidmap command to display and
>>> >> modify the NFSv4 domain name?
>> > I would think so... All the tools (aka conf_XXX() calls) are there 
>> > and I think it would be relatively simple...
> Any opinions about what command line options to use? How about:
> 
> To view:    nfsidmap -D
> 
> To update:  [sudo] nfsidmap -U new.domain.name
Just curious as to why upcase... I was thinking  -s / -d domain.name 
no big deal... either way is fine... 
> 
> On the client, updating the domain name requires "nfsidmap -c"
> to clear the kernel idmap keyring. That can be built in to -U.
That makes sense... as long as its documented... 
> 
> On the server, I guess restarting rpc.idmapd would also be
> required. Would be nice if server and client idmapping both used
> request-key.
I totally agree with this... Since the default on the server is 
to use uid/gid strings instead of name@domain strings it not 
clear how much the new up-call would be used.

> 
> 
>> > Another thing I always thought would be nice is a way 
>> > to show the existing uid/gid keys in a human format.
>> > Now to see what keys exist one has to cat /proc/keys
>> > which is not very readable... 
> Or use keyctl.
> 
> Either works for debugging and development, but neither are
> appropriate as an administrative interface, IMO.
Probably... but admin are curious people they might 
find some use for the interface. 

> 
> Something like "nfsidmap -l" would be simple, and could show
> both legacy and id_resolv keys, if we like.
Perfect! 

> 
> Btw, it looks like most recent kernels ignore the "-t" option.
> It should be fixed or removed.
I guess we could deprecate it. Its not clear how that was ever
used in the first place... I just added because I could... ;-) 

steved.
