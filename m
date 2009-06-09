From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 09 Jun 2009 11:27:16 -0400
Message-ID: <4A2E7F54.80500@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com> <7A24DF798E223B4C9864E8F92E8C93EC031D1B12@SACMVEXC1-PRD.hq.netapp.com> <20090608125957.3c8f0c95@tlielax.poochiereds.net> <EFEC3BA9-F125-4060-BC7C-9EE32A1D0174@oracle.com> <4A2E5714.3030502@RedHat.com> <2B0EDEC2-CA9F-4D43-B5F1-6EB5B04504DE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42461 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbZFIPaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 11:30:24 -0400
In-Reply-To: <2B0EDEC2-CA9F-4D43-B5F1-6EB5B04504DE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Jun 9, 2009, at 8:35 AM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>>
>>> On Jun 8, 2009, at 12:59 PM, Jeff Layton wrote:
>>>
>>>> On Mon, 8 Jun 2009 08:46:23 -0700
>>>> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
>>>>
>>>>>>
>>>>>> The reason to build without it is that libtirpc is largely
>>>>>> untested code (on Linux), and the nfs-utils support to use
>>>>>> TI-RPC is also largely untested.  I think the default config
>>>>>> settings should configure a safe, known-working
>>>>>> configuration, not the most advanced configuration.
>>>>>>
>>>>>> As much as I like the idea of wider testing, the idea that we
>>>>>> happen to be testing with live users is not inviting.  But I
>>>>>> guess it's all we've got at this point.
>>>>>
>>>>> It would be nice if RH had a way of testing this with Fedora without
>>>>> making it the default in the standard nfs-utils package until _after_
>>>>> testing.  Perhaps nfs-utils has evolved to the point where it could
>>>>> use
>>>>> a release-candidate model.  Then all distros could pull an RC build if
>>>>> they want it, while production users could pull the last "stable"
>>>>> release.
>>>>
>>>> This has very little to do with Red Hat. We can enable or disable TIRPC
>>>> in our own distros without making this change upstream. The question
>>>> here is whether we should make this the default now, or does it make
>>>> more sense to wait until everything has been converted to TIRPC, and
>>>> had IPv6 support added and *then* enable it.
>>>
>>> I disagree.
>>>
>>> The question about changing the upstream default came up because I asked
>>> RH to enable this option in Fedora so we can test first.  Steve doesn't
>>> want Fedora to enable TI-RPC unless upstream has it enabled by default.
>>>
>>> So this is _precisely_ about why RH won't enable this in Fedora first.
>> My concern, as with all package maintainers, is to keep their package
>> or git tree or whatever as stable as possible so as not to have a
>> negative on his or her community users....
>>
>> So my reluctance to make the switch in the Fedora Development stream,
>> called Rawhide, came from the concern of breaking the NFS components
>> what would have (as it has have) a very negative effect on entire
>> development of the next release (in this case F-12).
> 
> There must be something I don't understand.  Why would we foist
> something on all distributions (by placing it in upstream) that you
> wouldn't even put in a development distribution?  
It comes down to choice... If someone does a git pull and make install
from the upstream git tree and nfs-utils blows up breaking NFS
1) it on them to debug and fix or simply back it out 
2) It only effects them.

When an rawhide (or opensuse) user does a "system update to the latest
untested version" and nfs-utils blows up 
1) its on the package maintainer to (quickly) debug and fix or back out 
2) more importantly it effect the entire community until another 
   build cycle which can take up to 24 to 48 hours.
 
> My impression was that
> this kind of testing was exactly the purpose of rawhide and Fedora.  Is
> user space NFS special in this regard?  If so, how can we make progress
> if testing opportunities like this are not available to user space NFS?
Bug fixes, cleanups and minor enhancements (like enabling nfs41 support in
rpc.nfsd) are what I see development streams are for... But switching 
out an entire supporting library, replacing all the glibc RPC code 
is completely different... IMHO

steved.
