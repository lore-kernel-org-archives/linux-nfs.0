Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856Ab3KHQoY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 11:44:24 -0500
Message-ID: <527D1520.8030306@RedHat.com>
Date: Fri, 08 Nov 2013 11:45:20 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
References: <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com> <527CDBFC.3070903@RedHat.com> <20131108082202.4032f1a2@tlielax.poochiereds.net> <527CFC72.2030907@RedHat.com> <20131108101232.10d49851@tlielax.poochiereds.net> <527D0CE6.2020401@RedHat.com> <20131108161707.GD3533@fieldses.org> <527D0F21.3050200@RedHat.com> <20131108162203.GE3533@fieldses.org> <527D1112.3050903@RedHat.com> <20131108163913.GF3533@fieldses.org>
In-Reply-To: <20131108163913.GF3533@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/11/13 11:39, J. Bruce Fields wrote:
> On Fri, Nov 08, 2013 at 11:28:02AM -0500, Steve Dickson wrote:
>>
>>
>> On 08/11/13 11:22, J. Bruce Fields wrote:
>>> On Fri, Nov 08, 2013 at 11:19:45AM -0500, Steve Dickson wrote:
>>>>
>>>>
>>>> On 08/11/13 11:17, J. Bruce Fields wrote:
>>>>> On Fri, Nov 08, 2013 at 11:10:14AM -0500, Steve Dickson wrote:
>>>>>>
>>>>>>
>>>>>> On 08/11/13 10:12, Jeff Layton wrote:
>>>>>>> On Fri, 08 Nov 2013 10:00:02 -0500
>>>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> On 08/11/13 08:22, Jeff Layton wrote:
>>>>>>>>> On Fri, 08 Nov 2013 07:41:32 -0500
>>>>>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> On 07/11/13 18:05, Chuck Lever wrote:
>>>>>>>>>>>
>>>>>>>>>>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>>>>>>
>>>>>>>>>>>> Hey mrchuck... 
>>>>>>>>>>>>
>>>>>>>>>>>> On 07/11/13 14:25, Chuck Lever wrote:
>>>>>>>>>>>>> Hi Steve-
>>>>>>>>>>>>>
>>>>>>>>>>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>>>>>>>>>
>>>>>>>>>>>>>> This new module parameter makes the v4 client
>>>>>>>>>>>>>> use the minimal authentication flavor (AUTH_UNIX)
>>>>>>>>>>>>>> when establishing NFSV4 state and doing the
>>>>>>>>>>>>>> pseudoroot lookup
>>>>>>>>>>>>>
>>>>>>>>>>>>> The patch description doesn't say, but is this change to work 
>>>>>>>>>>>>> around the 15 second GSSD upcall timeout? 
>>>>>>>>>>>> Yes. A 15 second delay on every mount due to security that
>>>>>>>>>>>> nobody is requesting is just not good.. IMHO..
>>>>>>>>>>>
>>>>>>>>>>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
>>>>>>>>>>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
>>>>>>>>>>> you expect the mount to work (ie why would it be good for any properly configured 
>>>>>>>>>>> environment to take 15 seconds to establish a GSS context?).
>>>>>>>>>>>
>>>>>>>>>>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
>>>>>>>>>>> and not because of the use of krb5i for lease management.  Aren't those of concern?
>>>>>>>>>> No. I think the concern here, at least my concern, is the lack of management.
>>>>>>>>>> We are forcing admins to use krb5i in lease management when its not necessary
>>>>>>>>>> and there is no way to turn it off.
>>>>>>>>>>   
>>>>>>>>>
>>>>>>>>> I don't think that's really the case. The idea was to have the client
>>>>>>>>> attempt to use krb5i if it's available, and then to fall back to
>>>>>>>>> AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
>>>>>>>>> GSSAPI upcall succeeded or failed immediately instead of requiring this
>>>>>>>>> timeout when the daemon isn't running.
>>>>>>>> What server makes krb5i available today in state setup and pseudoroot lookups?
>>>>>>>>
>>>>>>>
>>>>>>> That I don't know...sorry...
>>>>>> Then what is the justification to take all these extra steps
>>>>>> there they going to fail %100 of the time??
>>>>>
>>>>> Any server can support krb5 for state setup and pseudoroot operations if
>>>>> it's configured.  This isn't a problem.
>>>> Would is this done on a Linux server? Is there a wiki?
>>>
>>> It's allowed by default, there should be nothing to configure beyond the
>>> usual krb5 setup.
>> Great! So you are saying when rpc.gssd is up and  Kerberos is correctly 
>> configured on both the server and client the state setup and pseudoroot
>> become secured? 
> 
> Yes.
> 
> There's one possible exception: I think mountd currently may not allow
> krb5 on the pseudoroot if it's not allowed on some export?
> 
> We could fix that if it's a problem here.  (I don't think it is, because
> a client mounting with auth_sys will fall back on auth_sys in this case,
> and a client mounting with sec=krb5 is going to fail eventually anyway.)
> 
> The server will allow state setup regardless.
This is good to know... Thanks!

> 
>> And this is the case with other non-Linux servers? 
> 
> Yes, the client's always used krb5 for all that setup at least in the
> case where the first mount uses sec=krb5.  And we test that at
> connectathon/bakeathon, and it's probably one of the first things anyone
> writing new gss support for a server would try.
It would be good to get all this documented... If its not already...

steved.

> 
> --b.
> 
