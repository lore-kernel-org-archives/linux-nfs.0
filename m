Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47226 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbG3SpD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 14:45:03 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: managing the system's NFSv4 domain name
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55BA6CF9.7080505@RedHat.com>
Date: Thu, 30 Jul 2015 14:44:58 -0400
Cc: Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <54623152-0EF7-4E04-AFB6-8928830F1B4B@oracle.com>
References: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com> <55BA2902.2020903@RedHat.com> <CF4DF6BD-CACC-4C75-98CF-DE5E26F10AE7@oracle.com> <55BA6CF9.7080505@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 30, 2015, at 2:29 PM, Steve Dickson <SteveD@redhat.com> wrote:

> Hey Chuck
> 
> On 07/30/2015 11:17 AM, Chuck Lever wrote:
>>>>>> Does it make sense to extend the nfsidmap command to display and
>>>>>> modify the NFSv4 domain name?
>>>> I would think so... All the tools (aka conf_XXX() calls) are there 
>>>> and I think it would be relatively simple...
>> Any opinions about what command line options to use? How about:
>> 
>> To view:    nfsidmap -D
>> 
>> To update:  [sudo] nfsidmap -U new.domain.name
> Just curious as to why upcase...

"-u user" is already taken. "-d" is typically used to enable
debugging.

> I was thinking  -s / -d domain.name 
> no big deal... either way is fine... 

The important aspect is one dash option, one dash option
with required positional parameter. We can finalize the
exact letters after a prototype materializes.


>> Something like "nfsidmap -l" would be simple, and could show
>> both legacy and id_resolv keys, if we like.
> Perfect! 

I'm guessing the way this needs to work is to do the same
thing a "keyctl list" does, and then prettify the output.

I still wonder about including legacy keys. This version
of nfsidmap would probably never be run on a system that
uses the legacy upcall, unless you intend to backport
this to RHEL 6.


--
Chuck Lever



