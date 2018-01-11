Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754156AbeAKOVB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Jan 2018 09:21:01 -0500
Subject: Re: [PATCH RFC 0/3] Add server-side support for junctions to
 nfs-utils
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
 <20180109192100.GB18087@fieldses.org>
 <492B1883-83EE-40AF-AA8C-1B797D842E5E@oracle.com>
 <01acd06d-98d4-c6ff-5ef1-b6edbb447405@RedHat.com>
 <6D1A900F-3F5C-4D70-9466-69ECC4985544@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d3a5175c-a330-ac7a-67ed-19cfc5363ec1@RedHat.com>
Date: Thu, 11 Jan 2018 09:20:54 -0500
MIME-Version: 1.0
In-Reply-To: <6D1A900F-3F5C-4D70-9466-69ECC4985544@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/10/2018 02:42 PM, Chuck Lever wrote:
> 
> 
>> On Jan 10, 2018, at 12:13 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 01/09/2018 02:36 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Jan 9, 2018, at 2:21 PM, bfields@fieldses.org wrote:
>>>>
>>>> Thanks for doing this!  I may not get the chance to do a real review,
>>>> but I'm in favor of the basic idea.
>>>
>>> How do you feel about building support for junctions into mountd,
>>> and getting rid of the libnfsjunct DLL ?
>> I would rather not put new functionality in daemons that needs rpcbind.
>> With the idea of, someday, having clean v4-only configuration
>> (aka no mountd, statd, or lockd).
> 
> Hi Steve, junction support is not new functionality.
> 
> Currently, mountd handles junction support by loading a DLL
> called libnfsjunct. We did this because you didn't want to add
> an LDAP dependency to nfs-utils in order to support FedFS.
Right.. I remember now... 

> 
> What I'm proposing is that because we no longer need LDAP support,
> we could build support for NFS basic junctions directly into mountd.
> This would be straightforward: just put nfs-plugin.c under
> utils/mountd and link it in at build time. Then dump the logic to
> load a plug-in (or we could even conditionally compile it in or out).
I see... why would we do it conditionally? Are they ever coming back?

> 
> The NFS basic junction code is already being ported into nfs-utils
> to support the nfsref command.
> 
> The long-term implication is that this removes the pluggable API
> for supporting other types of junctions, like reparse points should
> Linux ever choose to implement them. Since Linux doesn't have these
> now, and it's not a standard API anyway, maybe this is moot and I
> should go ahead and rip out the plug-in logic.
I guess this answers my question above... They could come back
if reparse points is supported. 

> 
> 
>>>> On Mon, Jan 08, 2018 at 04:49:50PM -0500, Chuck Lever wrote:
>>>>> THIS IS AN UNTESTED RFC SERIES. I'm posting this for review only.
>>>>>
>>>>> A while back I announced the deprecation of fedfs-utils. There were
>>>>> a handful of components in fedfs-utils that we decided to keep. One
>>>>> of those keepers was the "nfsref" command. (The other was autofs
>>>>> support for /nfs4, which I hope Ian Kent is making progress on ;-)
>>>>>
>>>>> This is an RFC patch series to introduce "nfsref" to nfs-utils,
>>>>> minus the overhead of the LDAP / FedFS machinery. It also adds a
>>>>> version of libnfsjunct which mountd can dynamically load to handle
>>>>> non-FedFS junctions, replacing the same part from fedfs-utils.
>>>>>
>>>>> I didn't apply a lot of brain cells to this port, so it's perhaps a
>>>>> little larger than it needs to be. Still, it achieves a completely
>>>>> LDAP-free implementation. I'm interested in comments about the
>>>>> approach before I do more testing and refinement.
>>>>>
>>>>> ./configure --enable-junction --enable-caps
>>>>>
>>>>> is needed before building.
>>>>>
>>>>> Perhaps one thing that can be done is simply getting rid of the DLL
>>>>> and building junction support into mountd. I'm not sure if a
>>>>> transition period is necessary where the DLL is retained for a bit
>>>>> until fedfs-utils is entirely gone. Does anything but mountd use
>>>>> libnfsjunct ?
>> So nfsref is to manage NFS referrals... got it... which I think
>> is a good thing to put into nfs-utils.. but again I wold like
>> to move a way from using mountd for exporting stuff.
>>
>> I must admit my memory on how referrals work is a bet strained, 
>> but does it make any sense at all to move the referral code out 
>> of mountd and into a new command maybe called nfsexport. Then
>> have the kernel call up to that command (similar to how it
>> does with nfsidmap) to get the referrals info. That way
>> only nfsexport would link with libnfsjunct.
> 
> Since FedFS support is no longer needed, junction support
> could also be built directly into nfsexport (no separate DLL
> is necessary).
Got it... but a v4only exporter did seem to impress anybody ;-) 
> 
> 
>> Now I realize this has nothing to do with putting nfsref
>> into nfs-utils... I'm all for that... and I'm not asking you
>> to do the work... I'm thinking out loud... Does it 
>> make sense to use this opportunity to build new mechanisms 
>> to handle referrals and then possibly all exports??
>> Again, with the idea of eliminating need for legacy daemons.
> 
> I don't have any quarrel with carving out the non-network-exposed
> functionality of mountd and putting it in an upcall similar to
> nfsidmap. Seems like an entirely separate project, though, and
> probably a significant chunk of work.
It is... I was just floating the idea. 

> 
> Given the heightened security consciousness in today's world,
> sandboxing the network-exposed part is a sensible precaution
> for deployments that continue to need a MNT RPC service.
> 
> In the long run, IMO the existing mountd upcall is going to have
> to be replaced. The current upcall mechanism is limited to moving
> just a page of data; fs_locations and fs_locations_info can
> comprise more than a page. And the upcall API might have to be
> revisited carefully to support fs_locations_info.
nfsimdap uses keyrings to communicate with the kernel.
Maybe that could be used to replace the kernel upcalls?

steved.
