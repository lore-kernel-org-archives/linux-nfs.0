Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: managing the system's NFSv4 domain name
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55BA2902.2020903@RedHat.com>
Date: Thu, 30 Jul 2015 16:05:27 -0400
Cc: Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Benjamin Coddington <bcodding@redhat.com>
Message-Id: <DE4C7506-6323-4559-B884-4E8E4DB3114B@oracle.com>
References: <5E5505A2-44BA-4ED7-89A6-8639C0D068BF@oracle.com> <55BA2902.2020903@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


On Jul 30, 2015, at 9:39 AM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
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

Displaying the effective NFSv4 domain name is easy, but I don't
see anything in libnfsidmap's cfg.c that can write an updated
idmapd.conf file. As far as I can tell, cfg.c is only for reading
and parsing an existing config file.

Is anyone aware of extensions to cfg.c that can update a conf file?


--
Chuck Lever
