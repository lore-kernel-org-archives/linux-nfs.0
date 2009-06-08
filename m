From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 13:36:57 -0400
Message-ID: <DA7A1F8C-7CC8-4087-ABB0-2F1188C34C8D@oracle.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net> <200906051650.42007.vapier@gentoo.org> <20090606071153.164d92dd@tlielax.poochiereds.net> <7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com> <20090606160230.247d3ca3@tlielax.poochiereds.net> <4A2CD550.4090609@RedHat.com> <20090608071026.0b57fff8@tupile.poochiereds.net> <4A2D13DF.2040105@RedHat.com> <467512DC-2A83-4432-A29C-1688B021A1F5@oracle.com> <4A2D2862.3090303@RedHat.com> <20090608124140.3fa02688@tlielax.poochiereds.net> <CAFCBD84-FFEB-40FB-9594-40E4E17A8BE3@oracle.com> <20090608130012.0bea6215@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:47797 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbZFHRhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 13:37:21 -0400
In-Reply-To: <20090608130012.0bea6215-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2009, at 1:00 PM, Jeff Layton wrote:

> On Mon, 8 Jun 2009 12:50:59 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On Jun 8, 2009, at 12:41 PM, Jeff Layton wrote:
>>
>>> On Mon, 08 Jun 2009 11:04:02 -0400
>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>> Chuck Lever wrote:
>>>>> On Jun 8, 2009, at 9:36 AM, Steve Dickson wrote:
>>>>>> Jeff Layton wrote:
>>>>>>> On Mon, 08 Jun 2009 05:09:36 -0400
>>>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>> Jeff Layton wrote:
>>>>>>>>> On Sat, 6 Jun 2009 11:00:41 -0700
>>>>>>>>> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
>>>>>>>>>>> -----Original Message-----
>>>>>>>>>>> From: Jeff Layton [mailto:jlayton@redhat.com]
>>>>>>>>>>> Sent: Saturday, June 06, 2009 4:12 AM
>>>>>>>>>>> To: Mike Frysinger
>>>>>>>>>>> Cc: linux-nfs@vger.kernel.org
>>>>>>>>>>> Subject: Re: should we make --enable-tirpc the default in
>>>>>>>>>>> current nfs-utils?
>>>>>>>>>>>
>>>>>>>>>>> On Fri, 5 Jun 2009 16:50:41 -0400
>>>>>>>>>>> Mike Frysinger <vapier@gentoo.org> wrote:
>>>>>>>>>>>
>>>>>>>>>>>> On Friday 05 June 2009 13:36:34 Jeff Layton wrote:
>>>>>>>>>>>>> On Fri, 5 Jun 2009 12:24:39 -0400 Mike Frysinger wrote:
>>>>>>>>>>>>>> On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
>>>>>>>>>>>>>>> Doing this now would add wider testing exposure for  
>>>>>>>>>>>>>>> these
>>>>>>>>>>>>>>> codepaths and help flush out bugs in TIRPC+IPV4
>>>>>>>>>>> codepaths. OTOH,
>>>>>>>>>>>>>>> it means adding a new library dependency for  
>>>>>>>>>>>>>>> packagers, or
>>>>>>>>>>>>>>> they'll need to take the conscious step to
>>>>>>>>>>> --disable-tirpc when they configure.
>>>>>>>>>>>>>> or have the configure script dump a warning whenever
>>>>>>>>>>> libtirpc is
>>>>>>>>>>>>>> not used ...
>>>>>>>>>>>>> The problem there is that these sorts of warnings tend to
>>>>>>>>>>> get lost
>>>>>>>>>>>>> in the noise. So then you have the situation where people
>>>>>>>>>>>>> aren't
>>>>>>>>>>>>> sure whether they built against libtirpc or not. Only
>>>>>>>>>>>>> running ldd
>>>>>>>>>>>>> against the binaries will tell you.
>>>>>>>>>>>> the configure script knows whether it's going to be
>>>>>>>>>>> building against libtirpc.
>>>>>>>>>>>> it isnt going to happen randomly during `make`.
>>>>>>>>>>>> AC_MSG_WARNING([
>>>>>>>>>>>>
>>>>>>>>>>>> You really should think about switching to libtirpc
>>>>>>>>>>>>
>>>>>>>>>>>> ])
>>>>>>>>>>>>
>>>>>>>>>>>> maybe it's different in Gentoo, but people report configure
>>>>>>>>>>> warnings
>>>>>>>>>>>> all the time ;)
>>>>>>>>>>>>
>>>>>>>>>>> Well, Gentoo probably has a larger percentage of people
>>>>>>>>>>> compiling the sources. Other distros generally distribute  
>>>>>>>>>>> the
>>>>>>>>>>> binaries. But to be fair, it's not unreasonable to expect
>>>>>>>>>>> people who are compiling from sources to know what they're
>>>>>>>>>>> doing.
>>>>>>>>>>>
>>>>>>>>>>>>>>> We could make it so that configure looks for libtirpc
>>>>>>>>>>>>>>> and if
>>>>>>>>>>>>>>> it's not available, configures the build against legacy
>>>>>>>>>>>>>>> RPC
>>>>>>>>>>>>>>> interfaces. I think this is a bad idea however. While
>>>>>>>>>>> it should
>>>>>>>>>>>>>>> "just work" either way, there are some small behavioral
>>>>>>>>>>>>>>> differences when TIRPC support is built in. I think it's
>>>>>>>>>>>>>>> probably better to make enabling and disabling TIRPC
>>>>>>>>>>> a conscious step.
>>>>>>>>>>>>>> i think this is the correct behavior for unspecified
>>>>>>>>>>>>>> configure
>>>>>>>>>>>>>> flags
>>>>>>>>>>>>> In general, yes. In this case though I think it's
>>>>>>>>>>>>> reasonable to
>>>>>>>>>>>>> force people compiling the package without tirpc
>>>>>>>>>>> installed to take
>>>>>>>>>>>>> the conscious step to either install the right libs and
>>>>>>>>>>> headers, or
>>>>>>>>>>>>> to add --disable-tirpc.
>>>>>>>>>>>>>
>>>>>>>>>>>>> I think doing so will lead to a more deterministic
>>>>>>>>>>> outcome in this
>>>>>>>>>>>>> situation. If that's a problem however, I'm willing to
>>>>>>>>>>> listen to the
>>>>>>>>>>>>> reasoning and reconsider...
>>>>>>>>>>>> i just dont agree with having to re-run configure to "fix"
>>>>>>>>>>> a condition
>>>>>>>>>>>> that the configure script should already be able to handle.
>>>>>>>>>>> but i'm
>>>>>>>>>>>> speaking in general terms here, not specific to what you
>>>>>>>>>>>> propose as
>>>>>>>>>>>> that isnt exactly the same thing.  i dont feel too strongly
>>>>>>>>>>>> here,
>>>>>>>>>>>> especially since it doesnt affect me in any realistic way.
>>>>>>>>>>>> -mike
>>>>>>>>>>> Ok, fair enough. I don't feel terribly strongly about this
>>>>>>>>>>> either and that is the the conventional way that configure
>>>>>>>>>>> options work (don't fail unless absolutely necessary). I'll
>>>>>>>>>>> see about coding up a patch that makes --enable-tirpc the
>>>>>>>>>>> default but falls back to legacy RPC code with a warning if
>>>>>>>>>>> TIRPC libs/headers aren't present.
>>>>>>>>>> Changing the default because the code isn't sufficiently  
>>>>>>>>>> tested
>>>>>>>>>> strikes
>>>>>>>>>> me as a particularly bad idea.  If Red Hat wants more  
>>>>>>>>>> testing,
>>>>>>>>>> distribute nfs-utils with TIRPC enabled in Fedora, and _then_
>>>>>>>>>> change the
>>>>>>>>>> default in nfs-utils after more testing has occurred.
>>>>>>>>>> Delegating
>>>>>>>>>> testing to unsuspecting end-users (especially people who need
>>>>>>>>>> to
>>>>>>>>>> rebuild
>>>>>>>>>> in production environments) seems like an ideal way to cause
>>>>>>>>>> real
>>>>>>>>>> problems.
>>>>>>>>>>
>>>>>>>>> If users have TIRPC installed on their systems, why would we
>>>>>>>>> want to
>>>>>>>>> avoid using it? Pieces of this code (mount.nfs, for instance)
>>>>>>>>> are
>>>>>>>>> pretty much complete and working. There's no real reason to
>>>>>>>>> build
>>>>>>>>> these
>>>>>>>>> apps against legacy RPC now if we can help it.
>>>>>>>>>
>>>>>>>>>> And ffs, don't change the existing configure behavior.  When
>>>>>>>>>> nfs-utils
>>>>>>>>>> is supposed to build with TIRPC (e.g., when TIRPC is the
>>>>>>>>>> default),
>>>>>>>>>> the
>>>>>>>>>> configure should fail if TIRPC isn't installed.  Perhaps the
>>>>>>>>>> error
>>>>>>>>>> message on failure could suggest running configure with
>>>>>>>>>> --disable-tirpc.
>>>>>>>>>>
>>>>>>>>> nfs-utils is already builds with TIRPC. It also builds with
>>>>>>>>> legacy
>>>>>>>>> RPC.
>>>>>>>>> So in this discussion the first question is, "Is there some
>>>>>>>>> reason to
>>>>>>>>> not build against TIRPC when it's available on the machine?"
>>>>>>>>>
>>>>>>>>> Second question: "Should make configure bail out when TIRPC
>>>>>>>>> isn't
>>>>>>>>> available and force the user to specify --disable-tirpc on the
>>>>>>>>> command
>>>>>>>>> line, or should we make the build just fall back to legacy RPC
>>>>>>>>> when
>>>>>>>>> the
>>>>>>>>> right TIRPC libs/headers aren't present?"
>>>>>>>>>
>>>>>>>>> So far, I'm leaning toward "No" on the first question and to
>>>>>>>>> "automatically fall back" on the second question.
>>>>>>>> I concur on this approach... but would like to change the
>>>>>>>> flavour a bit
>>>>>>>> Meaning.. Lets take out any and all references to TIRPC and
>>>>>>>> replace
>>>>>>>> them with IPv6 support, since, ultimately, that's what were are
>>>>>>>> talking
>>>>>>>> about...
>>>>>>>>
>>>>>>>> So, if libtirpc exists, there will be IPv6 support. If not,
>>>>>>>> there will
>>>>>>>> not be IPv6 support...
>>>>>>>
>>>>>>> Yes, eventually we'll want to make IPv6 support default to "on"
>>>>>>> when
>>>>>>> TIRPC is present. If you look at the code though, there are
>>>>>>> #ifdef's
>>>>>>> for HAVE_LIBTIRPC and IPV6_SUPPORTED. These are currently
>>>>>>> controlled by
>>>>>>> separate configure options, but you cannot build in IPv6 support
>>>>>>> without TIRPC.
>>>>>>>
>>>>>>> In the interest of phasing in this support slowly, Chuck and I  
>>>>>>> are
>>>>>>> proposing that we enable TIRPC by default now, and keep IPv6
>>>>>>> support a
>>>>>>> separate option for the time being. Eventually, we'll want to
>>>>>>> turn on
>>>>>>> IPv6 support automatically when TIRPC is available.  I think it
>>>>>>> makes
>>>>>>> sense though to wait until we have some experience with TIRPC
>>>>>>> support
>>>>>>> in nfs-utils before we go all the way with turning on IPv6
>>>>>>> support by
>>>>>>> default.
>>>>>>>
>>>>>> Is there *any* IPv6 code working at all? We can always call the
>>>>>> support "experimental" until you guys are done...
>>>>>
>>>>> Yes, mount.nfs, showmount, and gssd are all working over IPv6.
>>>>> rpc.statd and rpc.nfsd are coming soon.
>>>> Good... Could we wait until rpc.statd and rpc.nfsd before
>>>> we turn the switch? I thinking it would make testing a bit
>>>> easier...
>>>>
>>>
>>> Well, IPv6 support in statd would finish up the client side IPv6
>>> support. IPv6 support in rpc.nfsd is really only going to be useful
>>> once we get mountd and exportfs finished.
>>>
>>> While IPv6 support is the driving reason for adding TIRPC support to
>>> nfs-utils, does it really make sense to turn on TIRPC and IPv6  
>>> support
>>> all at once? It seems like that'll mean twice the bug reports all at
>>> once.
>>>
>>>>>
>>>>>> I guess I just don't see why there has to be two switches for
>>>>>> this feature...
>>>>>
>>>>> Because people seem to want to disable IPv6 support completely on
>>>>> their
>>>>> systems...  Because there is a striking lack of infrastructure for
>>>>> IPv6
>>>>> support (including GUIs for configurating ip6tables, lack of IPv6
>>>>> support in NetworkManager, no IPv6 support in tcp_wrappers,
>>>>> inability to
>>>>> disable IPv6 support in the kernel without hacking it out of
>>>>> /etc/modprobe.conf, and so on)...  Because TI-RPC is one level of
>>>>> complexity, and IPv6 adds more complexity...
>>>>>
>>>>> We can probably remove --enable-ipv6, and just stick with
>>>>> --enable-tirpc, which implies IPv6 support, if you prefer that.
>>>> Actually I would like to do just the opposite... remove --enable-
>>>> tirpc
>>>> and stick with --enable-ipv6...
>>>>
>>>>> But it's a strange argument, when we have --enable-mount, -- 
>>>>> enable-
>>>>> nfsv4,
>>>>> and on and on.
>>>> Well, your examples are all defining functionality... not
>>>> libraries...
>>>>
>>>
>>> Right. I agree with Steve here. I think it makes sense to keep the
>>> knobs we expect people to twiddle to be for features and not
>>> necessarily for libs.
>>
>> I really don't understand why having TI-RPC in a library is important
>> here.
>>
>> --enable-tirpc is a feature knob.  Forget that it happens to be in a
>> library.  Either nfs-utils supports TI-RPC or it supports legacy RPC.
>> The external behavior of nfs-utils changes.
>>
>> Legacy RPC is in a library too.  It happens to be in a library that  
>> is
>> included by default, so configure doesn't have to figure out where  
>> RPC
>> support is and whether it is installed.
>>
>> What's the difference?
>>
>
> Ok, fair enough. The question still stands. Why should we turn off  
> TIRPC
> support when we could build it in? At some point we're going to want  
> to
> make the switch. Why not now?

Because TI-RPC support hasn't been widely tested yet, and we don't  
have a complete implementation in nfs-utils atm.  It's really an early  
adopter thing right now; not ready for prime time.

The reason I added --enable-tirpc is to allow distributors to keep it  
turned off as we build TI-RPC support into nfs-utils.  That way, early  
adopters can enable it and try out the pieces that are working, and  
distributors have a better guarantee that when they download and build  
the latest upstream nfs-utils, things will pretty much work with the  
default configure settings.

Since we are not done adding TI-RPC support to nfs-utils, we should  
expect some bugs, and some code churn, as we finish up.  I think we  
want to prevent exposing that risk to distributors to as great an  
extent as possible.

Suppose some serious security bug crops up in nfs-utils.  A  
distribution doesn't want to download and build the latest nfs-utils,  
only to find out that they can't fix the security bug without adding a  
bunch of untested TI-RPC code, or go off on a potentially lengthy  
porting project to get just the bug fix they need.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
