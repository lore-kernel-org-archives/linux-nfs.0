Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752786AbcLGOVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 09:21:14 -0500
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove
 nfs-config.service
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <ab0ce4e9-fd03-7cee-5ce2-5317c522db8f@RedHat.com>
 <87inqw4qok.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <4b2acea2-3ce8-44a6-e3e3-f66f69a198b9@RedHat.com>
Date: Wed, 7 Dec 2016 09:21:13 -0500
MIME-Version: 1.0
In-Reply-To: <87inqw4qok.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2016 05:51 PM, NeilBrown wrote:
> On Wed, Dec 07 2016, Steve Dickson wrote:
> 
>> On 12/01/2016 10:58 PM, NeilBrown wrote:
>>> This is an RFC series.  A little voice at the back of my head keeps
>>> telling me that I'm over-engineering, but there isn't really that much
>>> new code, and I think the result has a lot to recommend it.
>>>
>>> But please tell me if I'm wrong.
>>>
>>> - Various daemons (not all) are enhance to accept configuration
>>>   information from /etc/nfs.conf
>>> - the conffile reader is enhanced to support include files, and
>>>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>>>   files usefully
>>> - nfs-config.service is removed, because it isn't really needed with
>>>   the above.
>>> - documentation for all the above is provided, including a new
>>>   nfs.systemd man page which gives the bigger picture.
>>>
>> Here is the nfs.conf I will be using to do my testing... 
>> I'm just wondering if this is something we should put in the git tree? 
>>
>> #
>> # This is a general conifguration for the 
>> # NFS daemons and tools
>> #
>> #[nfsdcltrack]
>> # storagedir=/var/lib/nfs/nfsdcltrack
>> #
>> #[nfsd]
>> # threads=8
>> # grace-time=90
>> # lease-time=90
>> # udp=y
>> # tcp=y
>> # vers2=n
>> # vers3=y
>> # vers4=y
>> # vers4.0=y
>> # vers4.1=y
>> # vers4.2=y
>> # rdma=n
>> # 
>> #[mountd]
>> # manage_gids=n
>> # descriptors=0
>> # port=42258
>> # threads=1
>> # reverse-lookup=n
>> # state-directory-path=/var/lib/nfs
>> # ha-callout=NULL
> 
> NULL??  That looks like it is meant to mean something.
> Ditto for the "port=0" below.
> 
> You seem to be listing the default here, in which case I would just have
> 
>   ha-callout=
Fine. 

> 
> Otherwise, this is probably a good idea.  People seem to prefer to fill
> in templates, rather than read documentation :-(
I'll check it in but I don't think its a good idea to
write any install rules... I don't want to blindly overwrite
the current configurations... I'll let the distros deal with
that. 

> 
>> #
>> #[statd]
>> # port=0
>> # outgoing-port=0
>> # name=NULL
>> # state-directory-path=/var/lib/nfs/statd
> 
> This is normally "/var/lib/nfs" - no "/statd".
Got it...

steved.

> 
>> # ha-callout=NULL
>> #
>> #[lockd]
>> # port=0
>> # udp-port=0
>> #
>> #[sm-notify]
>> # retry-time=900
>> # outgoing-port=NULL
>> # outgoing-addr=NULL
>> #
