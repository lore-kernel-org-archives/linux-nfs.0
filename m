Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:59112 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753709AbeBBRmk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 12:42:40 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: Question about random UDP port on rpcbind 0.2.3
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180202170001.qsrrt2znpamxa76k@tonberry.usersys.redhat.com>
Date: Fri, 2 Feb 2018 12:42:33 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Naruto Nguyen <narutonguyen2018@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <721345E6-C222-41E8-96FC-43B8607601FC@oracle.com>
References: <CANpxKHE=eKuFc2HBgT0aqDb+Q5EOFWOfCzf=tmmuH7zNyn878g@mail.gmail.com>
 <CANpxKHH3zf_RRnxckHKfvEWL-RNCr_ZePxc0r98Ep0X_JX1BbA@mail.gmail.com>
 <47c040cf-d0a8-eb42-a276-9bc2e264ff6e@RedHat.com>
 <66B30606-7AFE-43C8-8A51-5D031F9D744B@oracle.com>
 <27ec9304-5763-9885-b3c9-246c395e6986@RedHat.com>
 <1165B44B-0D40-42FF-94EE-9B852AD4C8FA@oracle.com>
 <20180201152918.am75vfq776vtj3i3@tonberry.usersys.redhat.com>
 <11614659-a3c9-b3c9-73e7-886e1f3d50a4@RedHat.com>
 <DCFA1F36-D6FA-4DFD-BBE1-389501A6CCA2@oracle.com>
 <2d7a93c3-815f-9f96-c672-da9c7d777bd0@RedHat.com>
 <20180202170001.qsrrt2znpamxa76k@tonberry.usersys.redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 2, 2018, at 12:00 PM, Scott Mayhew <smayhew@redhat.com> wrote:
>=20
> On Fri, 02 Feb 2018, Steve Dickson wrote:
>=20
>>=20
>>=20
>> On 02/02/2018 10:22 AM, Chuck Lever wrote:
>>>=20
>>>=20
>>>> On Feb 2, 2018, at 10:06 AM, Steve Dickson <SteveD@RedHat.com> =
wrote:
>>>>=20
>>>>=20
>>>>=20
>>>> On 02/01/2018 10:29 AM, Scott Mayhew wrote:
>>>>>=20
>>>>> This patch should take care of making rpcbind set up the remote =
call
>>>>> port on demand.  I don't have a whole lot of ways to test it =
though...
>>>>> just 'rpcinfo -b' and a handful of one-off programs I wrote a =
while back
>>>>> trying to mess with the CALLIT/INDIRECT/BCAST procedures.
>>>> This is where I spent my afternoon yesterday... figuring
>>>> out a way to test this code. rpc_call() is my new BFF!
>>>=20
>>> Thanks!
>>>=20
>>>=20
>>>>> I'd still need to add the stuff to retain CAP_NET_BIND_SERVICE.
>>>> I think we need to do what nsm_clear_capabilities() does.
>=20
> Right, I saw that and was going pretty much copy what it does... I =
just
> got busy bug hunting some other stuff.
>=20
>>>=20
>>> Agree, that's exactly what is needed to allow bindresvport
>>> on demand, if rpcbind (or statd) does not run as root.
>> With Fedora, rpcbind runs as 'rpc' and statd runs as 'rpcuser'
>> So changing the capabilities would have to happen early on.
>=20
> statd calls 'prctl(PR_SET_KEEPCAPS,...', calls =
setgroups/setgid/setuid,
> and then nsm_clear_capabilities right after that.
>=20
>>=20
>>>=20
>>> The only issue I see is that some distros might not have
>>> libcap. There is plenty of infrastructure in nsm/file.c that
>>> deals with the "libcap absent" case, which makes me wonder.
>> IDK... Fedora has it...=20
>=20
> So in the case of libcap being absent, I guess it comes down to who's
> actually using the functionality (I've looked a few times in the past
> and never really came up with anything), what program they're trying =
to
> call and what procedure they're trying to call... because if we fail =
to
> get a reserved port then we'll do the bind again with a non-reserved
> port.  AFAIK non of the programs care if a NULL request comes from a
> reserved port or not.  And check_callit() filters out a lot of the =
other
> procedures (e.g. nothing other than NULL is forwarded to nfsd).

>>>>> I also like the idea of leaving this off by default and adding a
>>>>> command-line flag to enable it because I'm also not sure if anyone
>>>>> actually uses it... not to mention there's been at least one CVE =
in the
>>>>> past that exploited it (CVE-2015-7236, not sure if there are =
others).
>>>> I'm not a fan of this idea... I think on demand is a better way
>>>> to go... but what do I know?? ;-)
>>>>=20
>>>>> I'm not sure why rpcbind would list an outgoing port in it's =
portmap
>>>>> menu. Are you sure that this is the forwarding reflector port?
>>>>>=20
>>>> Yes... the listening fd is created by create_rmtcall_fd()
>>>> This is not the first time people have complained about
>>>> rpbind's rogue listening port :-(=20
>>>=20
>>> Hrm. If this is indeed a listening port, on demand bindresvport
>>> won't help (on demand will only fix outgoing ports). I had
>>> assumed there was a long-lived reserved port that was being
>>> used just for outgoing RPCs, just like statd.
>> No. create_rmtcall_fd() just calls svc_tli_create() which
>> does the bindresvport()...=20
>=20
> Right... I was under the impression that was so these requests could =
be
> handled asynchronously.  If rpcbind were to use clnt_call() to forward
> the request then I'd think it would be pretty easy to tie up rpcbind,
> no?

Yes, asynchrony is good. But I don't believe that asynchrony
requires a privileged listener.

IMO it would be better if we could somehow move the CALLIT
listener up into the dynamic port range (above 49151).

In fact that is appropriate for libtirpc to implement for
arbitrary RPC service listeners (including mountd).
svc_tli_create should simply hunt for an available high-numbered
port rather than using bindresvport by default.

_Listeners_ should have no problem using that high port range.

A listener might need to use a well-known port, though, that is
below 1024. In that case, I think svc_tli_create should just use
bind and the library caller needs to have the appropriate
privilege to make it stick.


>>> Does that listening port have to be in the privileged port range?
>> Taking a quick look at mountd and statd I didn't see any code
>> requiring a privileged port... Maybe to call into the kernel?
>=20
> statd needs the privileged port to talk to lockd.

Right, and that's an outgoing port, if my memory serves. The
reason statd holds onto this port is because statd was written a
very long time ago before Linux had libcap (I presume).

If instead it could retain CAP_NET_BIND_SERVICE before it dropped
its root privileges, then it could create that socket on demand,
use bindresvport, and then close it immediately.


--
Chuck Lever



