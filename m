From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Fri, 11 Jul 2008 15:11:29 -0400
Message-ID: <76bd70e30807111211m567e9f8cv38a975bbc9df5758@mail.gmail.com>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
	 <20080703204543.GI30918@fieldses.org>
	 <1215454820.19512.25.camel@localhost>
	 <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com>
	 <1215456693.19512.36.camel@localhost>
	 <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com>
	 <1215463877.19512.40.camel@localhost>
	 <C5841A2A-5178-405F-A5A5-1E8D1B77A419@oracle.com>
	 <20080711184054.GA19425@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:47072 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757116AbYGKTLd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 15:11:33 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1954735ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2008 12:11:30 -0700 (PDT)
In-Reply-To: <20080711184054.GA19425@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 11, 2008 at 2:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jul 10, 2008 at 01:27:47PM -0400, Chuck Lever wrote:
>>
>> On Jul 7, 2008, at 4:51 PM, Trond Myklebust wrote:
>>
>>> On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:
>>>
>>>> If you would like connected UDP, I won't object to you implementing
>>>> it.  However, I never tested whether a connected UDP socket will give
>>>> the desired semantics without extra code in the UDP transport (for
>>>> example, an ->sk_error callback).  I don't think it's worth the
>>>> hassle
>>>> if we have to add code to UDP that only this tiny use case would
>>>> need.
>>>>
>>>
>>> OK. I'll set these patches aside until I have time to look into adding
>>> connected UDP support.
>>
>> That's not completely necessary... the one-shot + TCP changes just make
>> it nicer when the local rpcbind is not listening.  Without these, the
>> cases where the rpcbind daemon isn't running, or doesn't support rpcbind
>> v3/v4 and the kernel was built with CONFIG_SUNRPC_REGISTER_V4, will cause
>> some delays before failing, but otherwise shouldn't be a problem.
>>
>> I think you can drop the patch to change rpcb registration to go over
>> TCP for now unless you already have a CUDP implementation you are happy
>> with.
>
> So actually in your original series of 7 I think that'd mean dropping
> numbers 5 and 6 and keeping the rest?

So, 5/7 adds "one shot" support to the RPC client.  I think that might
be interesting for other kernel services, like making rpcbind queries
over TCP, or NFSv4 callback.  I'd like to advocate for keeping that
one so others can build on it (with whatever name for the create flag
we can agree on), but it's not really necessary for subsequent
patches.

6/7 changes the rpcb_register logic to use "one shot" + TCP -- that's
the one that is controversial and can be dropped.

> I've lost track of the status of the 3 series you submitted on the 30th:
>
>        "Remaining rpcbind patches for 2.6.27"
>                - this one, probably ready after dropping 2 patches

Yes.

>        "rpcbind v4 support in net/sunrpc/svc*"
>                - Do you still want this considered for 2.6.27?

Yes, please.

The default CONFIG setting added in this patch set should cause the
kernel to continue using portmap instead of rpcbindv3/v4 for RPC
service registration, so by default there shouldn't be any change in
behavior.

>        "NLM clean-ups for IPv6 support"
>                - I think you were saying there's still a bug being
>                  tracked down in this series?

There are probably a few bugs in this series, but I'd still like to
consider it for 2.6.27.  I think the architecture that is laid out
here is pretty solid, and we will have time to exercise this and get
it right in linux-next and during .27's -rc period.  Even if the whole
series is not included, I think there are good cleanups here that
should be solid enough to include.

The bug I mentioned last night is with lock recovery with NFSv3 over
IPv4, so it's not something that prevents NFSv2/v3 from working in
general.  We haven't had a decent lock recovery test until just
recently.

Can we assume this is going in for now, and start the review and
integration process?  I've already made a few minor changes in this
series since I posted these, so I'm sure I will have to post at least
one refresh.  But it would be useful to review this series carefully
now even if some or all of it is not going into 2.6.27.

Thanks for asking!

-- 
Chuck Lever
