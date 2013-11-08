Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:26164 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757457Ab3KHSJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Nov 2013 13:09:29 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131108161707.GD3533@fieldses.org>
Date: Fri, 8 Nov 2013 10:09:18 -0800
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <38DC086C-0EB7-42C3-9DCA-858A3225AAD0@oracle.com>
References: <1383851364-8370-1-git-send-email-steved@redhat.com> <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com> <527C07B4.800@RedHat.com> <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com> <527CDBFC.3070903@RedHat.com> <20131108082202.4032f1a2@tlielax.poochiereds.net> <527CFC72.2030907@RedHat.com> <20131108101232.10d49851@tlielax.poochiereds.net> <527D0CE6.2020401@RedHat.com> <20131108161707.GD3533@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 8, 2013, at 8:17 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Nov 08, 2013 at 11:10:14AM -0500, Steve Dickson wrote:
>> 
>> 
>> On 08/11/13 10:12, Jeff Layton wrote:
>>> On Fri, 08 Nov 2013 10:00:02 -0500
>>> Steve Dickson <SteveD@redhat.com> wrote:
>>> 
>>>> 
>>>> 
>>>> On 08/11/13 08:22, Jeff Layton wrote:
>>>>> On Fri, 08 Nov 2013 07:41:32 -0500
>>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>>> 
>>>>>> 
>>>>>> 
>>>>>> On 07/11/13 18:05, Chuck Lever wrote:
>>>>>>> 
>>>>>>> On Nov 7, 2013, at 1:35 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>>>>> 
>>>>>>>> Hey mrchuck... 
>>>>>>>> 
>>>>>>>> On 07/11/13 14:25, Chuck Lever wrote:
>>>>>>>>> Hi Steve-
>>>>>>>>> 
>>>>>>>>> On Nov 7, 2013, at 11:09 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>>>>> 
>>>>>>>>>> This new module parameter makes the v4 client
>>>>>>>>>> use the minimal authentication flavor (AUTH_UNIX)
>>>>>>>>>> when establishing NFSV4 state and doing the
>>>>>>>>>> pseudoroot lookup
>>>>>>>>> 
>>>>>>>>> The patch description doesn't say, but is this change to work 
>>>>>>>>> around the 15 second GSSD upcall timeout? 
>>>>>>>> Yes. A 15 second delay on every mount due to security that
>>>>>>>> nobody is requesting is just not good.. IMHO..
>>>>>>> 
>>>>>>> One thing we haven't discussed is reducing the upcall timeout to 5 seconds or less, 
>>>>>>> as a form of immediate relief.  15 seconds is arbitrary, and is onerous even when 
>>>>>>> you expect the mount to work (ie why would it be good for any properly configured 
>>>>>>> environment to take 15 seconds to establish a GSS context?).
>>>>>>> 
>>>>>>> In other words, there are still cases where users wait 15 seconds unnecessarily, 
>>>>>>> and not because of the use of krb5i for lease management.  Aren't those of concern?
>>>>>> No. I think the concern here, at least my concern, is the lack of management.
>>>>>> We are forcing admins to use krb5i in lease management when its not necessary
>>>>>> and there is no way to turn it off.
>>>>>> 
>>>>> 
>>>>> I don't think that's really the case. The idea was to have the client
>>>>> attempt to use krb5i if it's available, and then to fall back to
>>>>> AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
>>>>> GSSAPI upcall succeeded or failed immediately instead of requiring this
>>>>> timeout when the daemon isn't running.
>>>> What server makes krb5i available today in state setup and pseudoroot lookups?
>>>> 
>>> 
>>> That I don't know...sorry...
>> Then what is the justification to take all these extra steps
>> there they going to fail %100 of the time??
> 
> Any server can support krb5 for state setup and pseudoroot operations if
> it's configured.  This isn't a problem.

I let this pass earlier, but...

The krb5i setting is _ONLY_ for lease management, not for data access.  Traversing the pseudo-fs counts as data access.  Our client is supposed to use the security flavor specified on the mount command line for the pseudo-fs.  (That's why the pseudo-fs security policy is the union of all the real exports on the server, right?)

If no flavor is specified by the client administrator, we have SECINFO_NONAME for negotiating the pseudo-fs security flavor in NFSv4.1, and some roughly equivalent heuristics for this in NFSv4.0, which doesn't have the SECINFO_NONAME operation.  Since 3.11, I believe, our client should be using these mechanisms instead of just plowing ahead with AUTH_SYS.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



