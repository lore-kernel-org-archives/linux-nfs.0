From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Tue, 09 Jun 2009 08:58:53 -0400
Message-ID: <4A2E5C8D.2080700@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>	<20090606160230.247d3ca3@tlielax.poochiereds.net>	<861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>	<200906081023.58679.vapier@gentoo.org>	<7A24DF798E223B4C9864E8F92E8C93EC031D1B02@SACMVEXC1-PRD.hq.netapp.com> <20090608124913.7340074c@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36061 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757465AbZFINCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 09:02:05 -0400
In-Reply-To: <20090608124913.7340074c-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Jeff Layton wrote:
> On Mon, 8 Jun 2009 08:36:34 -0700
> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
> 
>>  
>>
>>> -----Original Message-----
>>> From: Mike Frysinger [mailto:vapier@gentoo.org] 
>>> Sent: Monday, June 08, 2009 7:24 AM
>>> To: Chuck Lever
>>> Cc: Jeff Layton; Muntz, Daniel; linux-nfs@vger.kernel.org
>>> Subject: Re: should we make --enable-tirpc the default in 
>>> current nfs-utils?
>>>
>>> On Monday 08 June 2009 10:16:07 Chuck Lever wrote:
>>>> Frankly, I think dropping back automatically is not a good 
>>> idea.  The 
>>>> torrent of messages that configure normally spits out means that 
>>>> messages about a missing libtirpc are going to be missed in most 
>>>> cases, and folks will think that because they specified 
>>> --enable-tirpc 
>>>> on the configure command line, that's the build they got.
>>> the automatic fallback is when no tirpc option is specified.  
>>> if --enable- tirpc is specified, then it should fail (and 
>>> that is what the proposed patch does).
>>> -mike
>>>
>> When libnfsidmap, libgssglue, etc. are not present the build fails.  The
>> builder didn't specify any particular --enable-X flag, and the build
>> doesn't just do something like fall back and build v3-only.  Why would I
>> want the build to nondeterministically (to the extent that one might not
>> be aware of what libraries are installed) generate different code?
>>
> 
> The build only fails if you have enabled features that require them.
> For instance it only requires libgssglue if --enable-gss is on. That
> gets turned on by default. You could probably make a case for
> turning off the feature of the required libs weren't available, but at
> some point autoconf becomes a maze of twisty options and fallbacks.
> 
I actual I like the fact that if --enable-gss is enabled and the
correct libs are not install, the configuration fails...
I think that's the right thing to do...

steved.

