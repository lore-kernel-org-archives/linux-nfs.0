From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 13:46:03 -0400
Message-ID: <91FFD4F1-3A0E-4E19-B224-48867DA8D481@oracle.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com> <7A24DF798E223B4C9864E8F92E8C93EC031D1B12@SACMVEXC1-PRD.hq.netapp.com> <20090608125957.3c8f0c95@tlielax.poochiereds.net> <EFEC3BA9-F125-4060-BC7C-9EE32A1D0174@oracle.com> <20090608131024.6aa0c020@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Muntz, Daniel" <Dan.Muntz@netapp.com>,
	"Mike Frysinger" <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:48568 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbZFHRqc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 13:46:32 -0400
In-Reply-To: <20090608131024.6aa0c020-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2009, at 1:10 PM, Jeff Layton wrote:

> On Mon, 8 Jun 2009 13:05:26 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On Jun 8, 2009, at 12:59 PM, Jeff Layton wrote:
>>
>>> On Mon, 8 Jun 2009 08:46:23 -0700
>>> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
>>>
>>>>>
>>>>> The reason to build without it is that libtirpc is largely
>>>>> untested code (on Linux), and the nfs-utils support to use
>>>>> TI-RPC is also largely untested.  I think the default config
>>>>> settings should configure a safe, known-working
>>>>> configuration, not the most advanced configuration.
>>>>>
>>>>> As much as I like the idea of wider testing, the idea that we
>>>>> happen to be testing with live users is not inviting.  But I
>>>>> guess it's all we've got at this point.
>>>>
>>>> It would be nice if RH had a way of testing this with Fedora  
>>>> without
>>>> making it the default in the standard nfs-utils package until  
>>>> _after_
>>>> testing.  Perhaps nfs-utils has evolved to the point where it could
>>>> use
>>>> a release-candidate model.  Then all distros could pull an RC build
>>>> if
>>>> they want it, while production users could pull the last "stable"
>>>> release.
>>>
>>> This has very little to do with Red Hat. We can enable or disable
>>> TIRPC
>>> in our own distros without making this change upstream. The question
>>> here is whether we should make this the default now, or does it make
>>> more sense to wait until everything has been converted to TIRPC, and
>>> had IPv6 support added and *then* enable it.
>>
>> I disagree.
>>
>> The question about changing the upstream default came up because I
>> asked RH to enable this option in Fedora so we can test first.  Steve
>> doesn't want Fedora to enable TI-RPC unless upstream has it enabled  
>> by
>> default.
>>
>> So this is _precisely_ about why RH won't enable this in Fedora  
>> first.
>
> Steve asked whether we should also make it the default. He stated that
> he would prefer that it was the upstream default first, but didn't NAK
> turning it on in fedora if we didn't make it the default there.
>
> So I disagree back :)
>
> The discussion of turning this on in Fedora brought about this  
> question
> for upstream, but it's a legitimate question for upstream code
> regardless of what happens with Fedora.

I brought this up because this upstream code hasn't had wide enough  
testing.  In my view, enabling TI-RPC in Fedora (or in some other  
development distribution) is a pre-requisite for making it the default  
in upstream.  As Fedora (and perhaps OpenSuSE) is the only  
distribution I'm aware of that has TI-RPC, that's why we might want to  
consider testing there first.

So, to answer your question, IMO enabling TI-RPC upstream now is  
jumping the gun.

>>> I believe the latter option will be more disruptive. Phasing support
>>> in
>>> slowly makes sense and there's an easy "fix" for people who find  
>>> they
>>> have problems with it (--disable-tirpc).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
