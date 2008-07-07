From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 7 Jul 2008 15:44:17 -0400
Message-ID: <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
	 <20080703204543.GI30918@fieldses.org>
	 <1215454820.19512.25.camel@localhost>
	 <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com>
	 <1215456693.19512.36.camel@localhost>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:14438 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896AbYGGToX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2008 15:44:23 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1041534ywe.1
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2008 12:44:18 -0700 (PDT)
In-Reply-To: <1215456693.19512.36.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 7, 2008 at 2:51 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2008-07-07 at 14:43 -0400, Chuck Lever wrote:
>> On Jul 7, 2008, at 2:20 PM, Trond Myklebust wrote:
>> > On Thu, 2008-07-03 at 16:45 -0400, J. Bruce Fields wrote:
>> >> On Mon, Jun 30, 2008 at 06:38:35PM -0400, Chuck Lever wrote:
>> >>> Hi Trond-
>> >>>
>> >>> Seven patches that implement kernel RPC service registration via
>> >>> rpcbind v4.
>> >>> This allows the kernel to advertise IPv4-only services on hosts
>> >>> with IPv6
>> >>> addresses, for example.
>> >>
>> >> This is Trond's baliwick, but I read through all 7 quickly and they
>> >> looked good to me....
>> >
>> > They look more or less OK to me too, however I'm a bit unhappy about
>> > the
>> > RPC_TASK_ONESHOT name: it isn't at all descriptive.
>>
>> Open to suggestions.  I thought RPC_TASK_FAIL_WITHOUT_CONNECTION was a
>> bit wordy ;-)
>
> RPC_TASK_CONNECT_ONCE ?

That's not the semantic I was really going for.  FAIL_ON_CONNRESET is
probably closer.

>> > I also have questions about the change to a TCP socket here. Why not
>> > just implement connected UDP sockets?
>>
>> Changing rpcb_register() to use a TCP socket is less work overall, and
>> we get a positive hand shake between the kernel and user space when
>> the TCP connection is opened.
>>
>> Other services might also want to use TCP+ONESHOT for several short
>> requests over a real network with actual packet loss, but they might
>> find CUDP+ONESHOT less practical/reliable (or even forbidden in the
>> case of NFSv4).  So we would end up with something of a one-off
>> implementation for rpcb_register.
>
> I don't see what that has to do with anything: the connection failed
> codepath in call_connect_status() should be the same in both the TCP and
> the UDP case.

If you would like connected UDP, I won't object to you implementing
it.  However, I never tested whether a connected UDP socket will give
the desired semantics without extra code in the UDP transport (for
example, an ->sk_error callback).  I don't think it's worth the hassle
if we have to add code to UDP that only this tiny use case would need.

>> The downside of using TCP in this case is that it's more overhead:  8
>> packets instead of two for registration in the common case, and it
>> leaves a single privileged port in TIME_WAIT for each registered
>> service.  I don't think this matters much as registration happens
>> quite infrequently.
>
> The problem is that registration usually happens at boot time, which is
> also when most of the NFS 'mount' requests will be eating privileged
> ports.

You're talking about the difference between supporting say 1358 mounts
at boot time versus 1357 mounts at boot time.

In most cases, a client with hundreds of mounts will use up exactly
one extra privileged TCP port to register NLM during the first
lockd_up() call.  If these are all NFSv4 mounts, it will use exactly
zero extra ports, since the NFSv4 callback service is not even
registered.

Considering that _each_ mount operation can take between 2 and 5
privileged ports, while registering NFSD and NLM both would take
exactly two ports at boot time, I think that registration is wrong
place to optimize.

-- 
Chuck Lever
