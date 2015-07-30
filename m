Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbbG3NjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 09:39:15 -0400
Message-ID: <55BA2902.2020903@RedHat.com>
Date: Thu, 30 Jul 2015 09:39:14 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <schumakeranna@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: managing the system's NFSv4 domain name
References: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com>
In-Reply-To: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/29/2015 10:28 PM, Chuck Lever wrote:
> Hi-
> 
> At least for testing purposes, it would be great to be able to
> manage a system's NFSv4 domain name from the command line. I'm
> frequently asked how to determine a system's NFSv4 domain name,
> and I'm forced to answer something like this:
> 
>> Linux does not currently have a command line tool for managing
>> the system's NFSv4 idmapping domain. Use:
>>
>> awk '/^Domain/ { print $3 }' < /etc/idmapd.conf
>>
>> If that fails to find anything, then use `dnsdomainname` . That
>> won't be helpful if the system has multiple i/f's.
> 
> 
> This doesn't even get into /proc/keys, or what to do to change
> the NFSv4 domainname, or the differences between rpc.idmapd and
> the keyring-based idmapper.
> 
> Linux now has hostnamectl and other tools to manage a system's
> hostname and so on. Solaris has sharectl, which can display and
> update the nfs4mapid_domain.
> 
> Does it make sense to extend the nfsidmap command to display and
> modify the NFSv4 domain name?
I would think so... All the tools (aka conf_XXX() calls) are there 
and I think it would be relatively simple... 

Another thing I always thought would be nice is a way 
to show the existing uid/gid keys in a human format.
Now to see what keys exist one has to cat /proc/keys
which is not very readable... 

steved. 
