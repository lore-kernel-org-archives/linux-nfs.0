Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:49727 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786Ab0L3Mws (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 07:52:48 -0500
Message-ID: <4D1C809B.30405@parallels.com>
Date: Thu, 30 Dec 2010 06:52:43 -0600
From: Rob Landley <rlandley@parallels.com>
To: "Kirill A. Shutemov" <kas@openvz.org>
CC: Rob Landley <rob@landley.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, <linux-nfs@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
References: <1293628470-28386-1-git-send-email-kas@openvz.org> <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com> <20101230085139.GA29697@shutemov.name> <4D1C4C7C.6050606@parallels.com> <20101230094433.GB29697@shutemov.name> <4D1C5953.6020200@parallels.com> <20101230104416.GA31824@shutemov.name> <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com> <20101230114514.GA31976@shutemov.name>
In-Reply-To: <20101230114514.GA31976@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/30/2010 05:45 AM, Kirill A. Shutemov wrote:
> On Thu, Dec 30, 2010 at 05:05:22AM -0600, Rob Landley wrote:
>> On Thu, Dec 30, 2010 at 4:44 AM, Kirill A. Shutemov<kas@openvz.org>  wrote:
>>> On Thu, Dec 30, 2010 at 04:05:07AM -0600, Rob Landley wrote:
>>>> On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
>>>>>>> If no rpcmount mountoption, no rpc_pipefs was found at
>>>>>>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
>>>>>>> init_rpc_pipefs.
>>>>>>
>>>>>> It's the "we are in init's mount namespace" that I was wondering about.
>>>>>>
>>>>>> So if I naievely chroot, nfs mount stops working the way it did before I
>>>>>> chrooted unless I do an extra setup step?
>>>>>
>>>>> No. It will work as before since you are still in init's mount namespace.
>>>>> Creating new mount namespace changes rules.
>>>>
>>>> Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs.  Got it.
>>>>
>>>> I'm kind of surprised that the kernel cares about a specific path under
>>>> /var/lib.  (Seems like policy in the kernel somehow.)
>>>
>>> Yep. It's bad, but there is way to overwrite the default.
>>>
>>> Other way is to leave 'rpcmount' mountoption without default.
>>> get_rpc_pipefs(NULL) in init's mount namespace will always return
>>> init_rpc_pipefs, without filesystem lookup.
>>> get_rpc_pipefs(NULL) in non-init's mount namespace will always return
>>> error.
>>>
>>> So you will have to specify 'rpcmount' mountoption for every nfs mount in
>>> container. Hmm, I guess, it may confuse user.
>>>
>>> Or we can try to move the default to userspace. /sbin/mount.nfs?
>>
>> /proc/sys/kernel/hotplug exists to tell the kernel where to find the hotplug
>> binary.  Once upon a time /sys/hotplug was the default value, and that was
>> there to overwrite it.  (They changed the default to blank (disabled) not due
>> to policy reasons, but due to adding the netlink hotplug notification
>> mechanism and making that the default.)
>>
>> I bring that up to point out that the general consensus about policy in the
>> kernel seems to be "when you really really can't avoid having any, make a
>> sane default the user can override".
>>
>> (Of course adding another entry to the crawling horror of /proc may not
>> be an improvement.  But individual overrides at the mount -o level seem
>> like a non-optimal granularity for this...)
>
> Do you propose to implement default as sysctl parameter?

I was pointing out it's been done before.

I'd prefer autodetecting it so new namespaces and the base namespace 
don't have magic policy _or_ require different mount invocations.  An 
ability to change the default for a value is less appealing than not 
needing the value in the first place.

And changing the default would probably have to be per-container anyway 
to be useful.  (Which isn't _quite_ the same as per-namespace since you 
can chroot without CLONE_NEWNS.)

(I keep thinking back to web service providers offering cheap web 
hosting "with root access" via openvz containers and such.  They're 
administering their own boxes, but aren't big iron guys.  This is yet 
another thing for them to understand that didn't apply to the linux box 
they have at home, and I'm just wondering if there's a way they don't 
have to.)

>>>> Can't it just
>>>> check the current process's mount list to see if an instance of
>>>> rpc_pipefs is mounted in the current namespace the way lxc looks for
>>>> cgroups?  Or are there potential performance/scalability issues with that?
>>>
>>> What should we do if we have several rpc_pipefs mounts in the namespace?
>>
>> You mean more than one inside a given process's view of the filesystem, taking
>> into account chroot like /proc/mounts does?
>>
>> Before this patch series, there was one instance systemwide.  The patch changed
>> that to look a fixed location in the filesystem relative to the
>> current chroot.  Either
>> way, there was one instance available to a given process doing an nfs mount.
>>
>> What's the use case for having more than one visible to a given process?
>> (NUMA scalability?  Some sort of multipath/VPN routing context?)
>
> It's no so obvious for me why we should restrict it. ;)

You can still provide a specific location with "-o rpcmount=/blah", 
correct?  So this isn't restricting it, this is autodetecting the 
default value, using the visible mount point of the appropriate type.

> Currently, there is no association between rpc_pipefs and mount namespace,

There is in that the root context doesn't need to have this mounted, and 
new namespaces do.  So there's an existing association between a LACK of 
a namespace and a different default behavior.

My understanding (correct me if I'm wrong) is that the historical 
behavior is that there's only one, and it doesn't actually live anywhere 
in the filesystem tree.  You're adding a special location.  I'm 
wondering if there's any way for that location not to be special.

> so I don't see simple way to restrict number of rpc_pipefs per mount
> namespace. Associating mount namespace with rpc_pipefs is not a good idea,
> I think.

I'm talking about associating a default rpc_pipefs instance with a 
namespace, which it seems to me you're already doing by emulating the 
legacy behavior.  Before you CLONE_NEWNS you get a magic default mount 
that doesn't exist in the tree.  After you CLONE_NEWNS you get something 
like -EINVAL unless you supply your own default.  (I'm actually not sure 
why new namespaces don't fall back to the magic global one...)

I'm suggesting that if the user doesn't specify -o rpcmount then the 
default could be the first rpc_pipefs mount visible to the current 
process context, rather than a specific path.  Logic to do that exists 
in the proc/self/mounts code (which I'm reading through now...).

(Your 00/12 post doesn't actually explain what can be _different_ about 
the various instances of rpc_pipefs, and hence why you'd want to mount 
it multiple times.  I'm still coming up to speed on the guts of NFS. 
The use case I'm trying to fix involves containers with different 
network routing than the host, and this looks like potentially part of 
the solution to that, but I'm still putting together enough context to 
work out how....)

Rob
