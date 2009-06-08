From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 10:16:07 -0400
Message-ID: <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Muntz, Daniel" <Dan.Muntz@netapp.com>,
	"Mike Frysinger" <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:39389 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbZFHOQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 10:16:31 -0400
In-Reply-To: <20090606160230.247d3ca3-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 6, 2009, at 4:02 PM, Jeff Layton wrote:

> On Sat, 6 Jun 2009 11:00:41 -0700
> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
>
>>
>>
>>> -----Original Message-----
>>> From: Jeff Layton [mailto:jlayton@redhat.com]
>>> Sent: Saturday, June 06, 2009 4:12 AM
>>> To: Mike Frysinger
>>> Cc: linux-nfs@vger.kernel.org
>>> Subject: Re: should we make --enable-tirpc the default in
>>> current nfs-utils?
>>>
>>> On Fri, 5 Jun 2009 16:50:41 -0400
>>> Mike Frysinger <vapier@gentoo.org> wrote:
>>>
>>>> On Friday 05 June 2009 13:36:34 Jeff Layton wrote:
>>>>> On Fri, 5 Jun 2009 12:24:39 -0400 Mike Frysinger wrote:
>>>>>> On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
>>>>>>> Doing this now would add wider testing exposure for these
>>>>>>> codepaths and help flush out bugs in TIRPC+IPV4
>>> codepaths. OTOH,
>>>>>>> it means adding a new library dependency for packagers, or
>>>>>>> they'll need to take the conscious step to
>>> --disable-tirpc when they configure.
>>>>>>
>>>>>> or have the configure script dump a warning whenever
>>> libtirpc is
>>>>>> not used ...
>>>>>
>>>>> The problem there is that these sorts of warnings tend to
>>> get lost
>>>>> in the noise. So then you have the situation where people aren't
>>>>> sure whether they built against libtirpc or not. Only running ldd
>>>>> against the binaries will tell you.
>>>>
>>>> the configure script knows whether it's going to be
>>> building against libtirpc.
>>>> it isnt going to happen randomly during `make`.
>>>> AC_MSG_WARNING([
>>>>
>>>> You really should think about switching to libtirpc
>>>>
>>>> ])
>>>>
>>>> maybe it's different in Gentoo, but people report configure
>>> warnings
>>>> all the time ;)
>>>>
>>>
>>> Well, Gentoo probably has a larger percentage of people
>>> compiling the sources. Other distros generally distribute the
>>> binaries. But to be fair, it's not unreasonable to expect
>>> people who are compiling from sources to know what they're doing.
>>>
>>>>>>> We could make it so that configure looks for libtirpc and if
>>>>>>> it's not available, configures the build against legacy RPC
>>>>>>> interfaces. I think this is a bad idea however. While
>>> it should
>>>>>>> "just work" either way, there are some small behavioral
>>>>>>> differences when TIRPC support is built in. I think it's
>>>>>>> probably better to make enabling and disabling TIRPC
>>> a conscious step.
>>>>>>
>>>>>> i think this is the correct behavior for unspecified configure
>>>>>> flags
>>>>>
>>>>> In general, yes. In this case though I think it's reasonable to
>>>>> force people compiling the package without tirpc
>>> installed to take
>>>>> the conscious step to either install the right libs and
>>> headers, or
>>>>> to add --disable-tirpc.
>>>>>
>>>>> I think doing so will lead to a more deterministic
>>> outcome in this
>>>>> situation. If that's a problem however, I'm willing to
>>> listen to the
>>>>> reasoning and reconsider...
>>>>
>>>> i just dont agree with having to re-run configure to "fix"
>>> a condition
>>>> that the configure script should already be able to handle.
>>> but i'm
>>>> speaking in general terms here, not specific to what you propose as
>>>> that isnt exactly the same thing.  i dont feel too strongly here,
>>>> especially since it doesnt affect me in any realistic way.
>>>> -mike
>>>
>>> Ok, fair enough. I don't feel terribly strongly about this
>>> either and that is the the conventional way that configure
>>> options work (don't fail unless absolutely necessary). I'll
>>> see about coding up a patch that makes --enable-tirpc the
>>> default but falls back to legacy RPC code with a warning if
>>> TIRPC libs/headers aren't present.
>>
>> Changing the default because the code isn't sufficiently tested  
>> strikes
>> me as a particularly bad idea.  If Red Hat wants more testing,
>> distribute nfs-utils with TIRPC enabled in Fedora, and _then_  
>> change the
>> default in nfs-utils after more testing has occurred.  Delegating
>> testing to unsuspecting end-users (especially people who need to  
>> rebuild
>> in production environments) seems like an ideal way to cause real
>> problems.
>
> If users have TIRPC installed on their systems, why would we want to
> avoid using it? Pieces of this code (mount.nfs, for instance) are
> pretty much complete and working. There's no real reason to build  
> these
> apps against legacy RPC now if we can help it.

The reason to build without it is that libtirpc is largely untested  
code (on Linux), and the nfs-utils support to use TI-RPC is also  
largely untested.  I think the default config settings should  
configure a safe, known-working configuration, not the most advanced  
configuration.

As much as I like the idea of wider testing, the idea that we happen  
to be testing with live users is not inviting.  But I guess it's all  
we've got at this point.

>> And ffs, don't change the existing configure behavior.  When nfs- 
>> utils
>> is supposed to build with TIRPC (e.g., when TIRPC is the default),  
>> the
>> configure should fail if TIRPC isn't installed.  Perhaps the error
>> message on failure could suggest running configure with --disable- 
>> tirpc.
>
> nfs-utils is already builds with TIRPC. It also builds with legacy  
> RPC.
> So in this discussion the first question is, "Is there some reason to
> not build against TIRPC when it's available on the machine?"

Yes, there is, I would argue.

> Second question: "Should make configure bail out when TIRPC isn't
> available and force the user to specify --disable-tirpc on the command
> line, or should we make the build just fall back to legacy RPC when  
> the
> right TIRPC libs/headers aren't present?"

In many other cases (libevent, libnfsidmap, libgssglue, and so on),  
configure currently bails if the library is not present.  If we make -- 
enable-tirpc drop back automatically, why wouldn't we also do this for  
the others?

Frankly, I think dropping back automatically is not a good idea.  The  
torrent of messages that configure normally spits out means that  
messages about a missing libtirpc are going to be missed in most  
cases, and folks will think that because they specified --enable-tirpc  
on the configure command line, that's the build they got.

> So far, I'm leaning toward "No" on the first question and to
> "automatically fall back" on the second question.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
