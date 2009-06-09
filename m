From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 09 Jun 2009 08:35:32 -0400
Message-ID: <4A2E5714.3030502@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com> <7A24DF798E223B4C9864E8F92E8C93EC031D1B12@SACMVEXC1-PRD.hq.netapp.com> <20090608125957.3c8f0c95@tlielax.poochiereds.net> <EFEC3BA9-F125-4060-BC7C-9EE32A1D0174@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54874 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753877AbZFIMil (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 08:38:41 -0400
In-Reply-To: <EFEC3BA9-F125-4060-BC7C-9EE32A1D0174@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> 
> On Jun 8, 2009, at 12:59 PM, Jeff Layton wrote:
> 
>> On Mon, 8 Jun 2009 08:46:23 -0700
>> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
>>
>>>>
>>>> The reason to build without it is that libtirpc is largely
>>>> untested code (on Linux), and the nfs-utils support to use
>>>> TI-RPC is also largely untested.  I think the default config
>>>> settings should configure a safe, known-working
>>>> configuration, not the most advanced configuration.
>>>>
>>>> As much as I like the idea of wider testing, the idea that we
>>>> happen to be testing with live users is not inviting.  But I
>>>> guess it's all we've got at this point.
>>>
>>> It would be nice if RH had a way of testing this with Fedora without
>>> making it the default in the standard nfs-utils package until _after_
>>> testing.  Perhaps nfs-utils has evolved to the point where it could use
>>> a release-candidate model.  Then all distros could pull an RC build if
>>> they want it, while production users could pull the last "stable"
>>> release.
>>
>> This has very little to do with Red Hat. We can enable or disable TIRPC
>> in our own distros without making this change upstream. The question
>> here is whether we should make this the default now, or does it make
>> more sense to wait until everything has been converted to TIRPC, and
>> had IPv6 support added and *then* enable it.
> 
> I disagree.
> 
> The question about changing the upstream default came up because I asked
> RH to enable this option in Fedora so we can test first.  Steve doesn't
> want Fedora to enable TI-RPC unless upstream has it enabled by default.
> 
> So this is _precisely_ about why RH won't enable this in Fedora first.
My concern, as with all package maintainers, is to keep their package
or git tree or whatever as stable as possible so as not to have a 
negative on his or her community users.... 

So my reluctance to make the switch in the Fedora Development stream,
called Rawhide, came from the concern of breaking the NFS components 
what would have (as it has have) a very negative effect on entire 
development of the next release (in this case F-12). 

So I like to "Bake" things in upstream for a while, to see how things
go. Because in the end, the people who are pulling directly from the 
git tree generally have clue and are very easy to work with because 
of their strong understanding of what they are doing...

Once it appears the new functionality somewhat "baked", I will gladly 
introduce the functionality into rawhide, which enables testing by 
a much broader community... which is a very good thing...

I have found that this theory has worked fairly well in the all
the packages I maintain.... Not to say things don't break... Just
ask the Fedora community about the time I broke mount.. My IRC 
window lit up so fast I thought it was on fire! 8-)

So in the end, its not the case I won't enable it, I just want to
take as many precautions as I can to ensure both streams, upstream
and rawhide stay as stable as possible...

steved.

