Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbaCXX53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 19:57:29 -0400
Message-ID: <5330C65B.6010904@RedHat.com>
Date: Mon, 24 Mar 2014 19:57:15 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@uvm.edu>
CC: linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
References: <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com>
In-Reply-To: <53308CD4.9020307@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 03/24/2014 03:51 PM, Steve Dickson wrote:
> 
> 
> On 03/24/2014 02:00 PM, Benjamin Coddington wrote:
>>
>> On Mar 24, 2014, at 1:00 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>> On 03/21/2014 05:08 PM, Benjamin Coddington wrote:
>>>> The kernel keyring has a max of ~508 entries on 64-bit systems.
>>>> For installations with more distict users than this limit, create
>>>> a specified number of child keyrings and fill them evenly.
>>> A couple things... 
>>>
>>> 1) no Signed-off-by: line
>>>
>>> 2) Its seems you can create key rings but can't delete them.
>>>   Here is what I'm doing:
>>>   in /etc/request-key.d/id_resolver.conf I have
>>>    create    id_resolver * *    /usr/sbin/nfsidmap -n 10 %k %d
>>> but when I tried to delete the keys
>>>    # nfsidmap -vc
>>>    nfsidmap: clearing '08aa156c I--Q---     1perm 3f010000     0     0 keyring   .id_resolver_child_10: empty'
>>>    nfsidmap: keyctl_clear(0x8aa156c) failed: Permission denied
>>
>> This mess works on my fleet of RHEL6 boxes which is where I was trying to fix this.  They create the child keyrings with
>>
>> perm 3b3f0000
>>
>> Instead of yours which appears to be
>>
>> perm 3f010000
>>
>> Are you testing on a later kernel?  Likely this behavior has changed.
> Yes... Much later... 
> 
>>
>>>> #define PROCKEYS "/proc/keys"
>>>> #ifndef DEFAULT_KEYRING
>>>> -#define DEFAULT_KEYRING "id_resolver"
>>>> +#define DEFAULT_KEYRING ".id_resolver"
>>> 3) Why is changing the default needed?
>>
>> The default is wrong.  I think that's the first thing I changed when 
>> trying to fix this problem, since it looked like id_lookup() should 
>> gracefully recover in the case that the keyring was full 
>> (but it still doesn't). 
> I'm think the "id_resolver" default can from the face 
> the entry /etc/request-key.d/id_resolver.conf 
> which tells nfsidmap put the keys on the id_resolver
> key ring... so I'm not really sure where the
> .id_resolver is coming from... CC-ing David Howells
> maybe he knows... 
To translate in king's English... 

The reason the default is "id_resolver" is because the
is the name of the key ring defined in id_resolver.conf
is id_resolver. Now how that is translated into ".id_resolver"
in /proc/keys is not clear.... 

steved.
