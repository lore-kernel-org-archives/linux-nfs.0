Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754438AbdC2NuL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Mar 2017 09:50:11 -0400
Subject: Re: notes on VAULT 2017 NFS BOF
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <20170324145907.GC2722@fieldses.org>
 <b77898fc-830d-6458-fe1e-86159fec92b6@RedHat.com>
 <20170329014557.GE20963@fieldses.org>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3c4752be-4daf-959b-b29d-f60ad4dbb949@RedHat.com>
Date: Wed, 29 Mar 2017 09:50:09 -0400
MIME-Version: 1.0
In-Reply-To: <20170329014557.GE20963@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/28/2017 09:45 PM, J. Bruce Fields wrote:
> On Sat, Mar 25, 2017 at 01:28:42PM -0400, Steve Dickson wrote:
>> On 03/24/2017 10:59 AM, J. Bruce Fields wrote:
>>> Should the client by default try NFSv4.2 first?  Consensus seems to be
>>> yes.  When 4.2 fails, it tries 4.1, then 4.0, etc.  It works
>>> transparently.  Steved was worried that those retries might become a
>>> problem on clients with lots of NFS mounts.  Trond suggested recording
>>> the result of the version negotiation across mounts, so a client doing a
>>> lot of mounts to the same server would only need the retries on the
>>> first mount.
>> I just don't think this scales very well in large NFS mounted
>> home directory server. Since the major enterprise  servers
>> do not support 4.2 and I don't see them supporting 4.2
>> anytime soon. Why try something when you know its going to fail? ;-) 
> 
> I'm OK with sticking with 4.1 for now.
> 
> That said, the expense of negotiation shouldn't be an issue.  We have
> ideas here for cutting that expense (if it really is an issue), and
> they'd help in the 4.1->4.0 case too.
> 
>> Starting at v4.2 in non-enterprise environments works, 
>> at least it has for the last few years... 
>>
>>> The retries are driven by userspace which does a mount for a specific
>>> version and uses the return from the mount call to decide to negotiate
>>> down.  So a new TCP connection happens for each mount attempt.
>> Well it could be up to 3 connection (including the successful mount)
>> when both the IPv4 and IPv6 address are tried.
> 
> Somebody correct me if I'm wrong, but I don't think that contributes to
> port exhaustion.  Connections to the IPv4 and IPv6 addresses using the
> same ports are distinct, aren't they?
IDK... I was just looking at the for loop in nfs_try_mount_v4()
count a connection for each loop... 

> 
>>> Miklos introduced a proposed new mount api at LSF earlier in the week.
>>> It would allow some communication with the file system driver to set up
>>> parameters before the system call that creates the mountpoint.  If we
>>> moved the mount negotiation to that setup phase, that might make the
>>> negotiation phase more efficient while still leaving userspace in
>>> charge.  (And we prefer leaving userspace in charge to give it maximum
>>> control over negotiation policy.)
>> Any pointers to this?
> 
> I googled around a little and can't find any.  It's still just a
> proposal, so there's nothing for us to build on yet.
Fair enough... thanks for looking!

steved.

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
