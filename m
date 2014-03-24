Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:60121 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaCXWKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Mar 2014 18:10:34 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so6732874qcx.4
        for <linux-nfs@vger.kernel.org>; Mon, 24 Mar 2014 15:10:33 -0700 (PDT)
Message-ID: <5330AD55.50004@gmail.com>
Date: Mon, 24 Mar 2014 18:10:29 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>, Benjamin Coddington <bcodding@uvm.edu>
CC: linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
References: <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com> <B126AD05-73BE-4395-BFED-F05B67856EAA@uvm.edu> <5330A217.6020607@RedHat.com>
In-Reply-To: <5330A217.6020607@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/24/2014 05:22 PM, Steve Dickson wrote:
>
> On 03/24/2014 05:03 PM, Benjamin Coddington wrote:
>> On Mar 24, 2014, at 3:51 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>>>> Finally, what -n value do plan on using? Maybe a blurb in the man page
>>>>> on what a good number is and why....
>>>> I've got this running now with -n160, since 
>>>> we have ~60K distinct uid/gid s.  Ideally, I'd like to re-submit 
>>>> this to self-scale which wouldn't require any sysadmin tuning, 
>>>> but I haven't had the time.  Really, this is just a quick fix 
>>>> for the brokenness that's in current RHEL and less-new Fedora.
>>> The brokenness in RHEL will be healing very soon... See 
>>> https://bugzilla.redhat.com/show_bug.cgi?id=1033708. RHEL is 
>>> basically going back to using rpc.idmapd on the client and
>>> nfsidmap is going away... It as just a bad dream... It never
>>> happen! ;-)
>> This BZ says the fix is coming in nfs-utils by removing the nfsidmap command.  
> Yeah.. I bet the RHEL police are not going to be happy about that... so I
> might have to put it back... 
>
>> But IIRC, unless the kernel side of the idmapper is changed, it will exec request-key 
>> for every lookup before falling back to the upcall, and there's no cache in front of that.  
>> Isn't that going to have some performance problems?  
> I don't thinks so, since things will eventually get cached but I'll definitely look into it... 

The fallback upcall version uses the "id_legacy" keyring to cache results.  A bigger keyring might be the best solution.

Anna
>
>> I'm much more interested in getting the keyrings to work, since they seem to 
>> offer significant performance gains.
> I too, but the back port of the current key is a bit too much for RHEL at this point.
>> If RH is going to change the kernel side of the idmapper to only upcall, then I'd be satisfied to use that.
> It was a bone-head decision on my part to flip this type of switch midstream... 
> I too just want to put things back to the way were,,,
>
> steved.
>
>> Ben
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

