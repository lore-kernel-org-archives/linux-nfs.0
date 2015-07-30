Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26341 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbbG3PRH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 11:17:07 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: managing the system's NFSv4 domain name
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55BA2902.2020903@RedHat.com>
Date: Thu, 30 Jul 2015 11:17:00 -0400
Cc: Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CF4DF6BD-CACC-4C75-98CF-DE5E26F10AE7@oracle.com>
References: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com> <55BA2902.2020903@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 30, 2015, at 9:39 AM, Steve Dickson <SteveD@redhat.com> wrote:

> On 07/29/2015 10:28 PM, Chuck Lever wrote:
>> Hi-
>> 
>> At least for testing purposes, it would be great to be able to
>> manage a system's NFSv4 domain name from the command line. I'm
>> frequently asked how to determine a system's NFSv4 domain name,
>> and I'm forced to answer something like this:
>> 
>>> Linux does not currently have a command line tool for managing
>>> the system's NFSv4 idmapping domain. Use:
>>> 
>>> awk '/^Domain/ { print $3 }' < /etc/idmapd.conf
>>> 
>>> If that fails to find anything, then use `dnsdomainname` . That
>>> won't be helpful if the system has multiple i/f's.
>> 
>> 
>> This doesn't even get into /proc/keys, or what to do to change
>> the NFSv4 domainname, or the differences between rpc.idmapd and
>> the keyring-based idmapper.
>> 
>> Linux now has hostnamectl and other tools to manage a system's
>> hostname and so on. Solaris has sharectl, which can display and
>> update the nfs4mapid_domain.
>> 
>> Does it make sense to extend the nfsidmap command to display and
>> modify the NFSv4 domain name?
> I would think so... All the tools (aka conf_XXX() calls) are there 
> and I think it would be relatively simple...

Any opinions about what command line options to use? How about:

To view:    nfsidmap -D

To update:  [sudo] nfsidmap -U new.domain.name

On the client, updating the domain name requires "nfsidmap -c"
to clear the kernel idmap keyring. That can be built in to -U.

On the server, I guess restarting rpc.idmapd would also be
required. Would be nice if server and client idmapping both used
request-key.


> Another thing I always thought would be nice is a way 
> to show the existing uid/gid keys in a human format.
> Now to see what keys exist one has to cat /proc/keys
> which is not very readable... 

Or use keyctl.

Either works for debugging and development, but neither are
appropriate as an administrative interface, IMO.

Something like "nfsidmap -l" would be simple, and could show
both legacy and id_resolv keys, if we like.

Btw, it looks like most recent kernels ignore the "-t" option.
It should be fixed or removed.


--
Chuck Lever



