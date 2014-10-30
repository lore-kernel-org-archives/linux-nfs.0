Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014AbaJ3QQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 12:16:58 -0400
Date: Thu, 30 Oct 2014 12:16:02 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: building upstream nfs-utils on EL6 fails
In-Reply-To: <26E7662C-9217-4720-9752-0969231472E8@oracle.com>
Message-ID: <alpine.LRH.2.11.1410301210320.20279@sh-el6.eng.rdu2.redhat.com>
References: <E823B0AB-32D7-45C5-B5C2-69B165A2CEAC@oracle.com> <alpine.LRH.2.11.1410291919090.20279@sh-el6.eng.rdu2.redhat.com> <0953ACF5-C77F-4568-9952-FAF0C126B4AD@oracle.com> <alpine.LRH.2.11.1410301022140.20279@sh-el6.eng.rdu2.redhat.com>
 <88A2F169-8D62-4F15-BAAE-42732903DE46@oracle.com> <26E7662C-9217-4720-9752-0969231472E8@oracle.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="168445344-2108265295-1414685762=:20279"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--168445344-2108265295-1414685762=:20279
Content-Type: TEXT/PLAIN; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8BIT


On Thu, 30 Oct 2014, Chuck Lever wrote:

>
> [ Replying to my earlier post ]
>
> On Oct 30, 2014, at 11:31 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>
>> On Oct 30, 2014, at 10:53 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
>>
>>>
>>> On Wed, 29 Oct 2014, Chuck Lever wrote:
>>>
>>>> Hi Ben-
>>>>
>>>> I’m not sure keyctl_revoke and keyctl_invalidate do
>>>> precisely the same thing, though? On older systems can
>>>> we expect a change from one to the other to have no
>>>> impact? (Just beginning to explore this issue).
>>>
>>> For EL6 kernels, you should be good with keyctl_revoke.  That's the only
>>> thing you can do - there's no key_invalidate.
>>>
>>> But on later kernels, you'd want to use key_invalidate.
>>
>> I realize that EL6 user space is not designed to support
>> newer kernels, but some distributions allow continuous
>> upgrades of kernels. If the kernel API changes over time,
>> then IMO user space tools need to be sensitive to what
>> kernel is running.
>>
>>> The details of the kernel changes are here:
>>>
>>> 0c7774abb41bd00d KEYS: Allow special keys (eg. DNS results) to be
>>> invalidated by CAP_SYS_ADMIN
>>
>> I think this means the EL6 nfsidmap no longer works quite
>> right when running 3.17. I’m still studying the problem.
>> See below.
>>
>>> The summary is that permission changes in later kernels cause
>>> keyctl_revoke to be unable to clean up keys that are not in possession.
>>> This specific commit allows that once more for CAP_SYS_ADMIN, so
>>> really, it should work fine if you have this.  However:
>>>
>>> keyctl_revoke waits key_gc_timeout to clean up the key, and access
>>> attempts return -EKEYREVOKED.
>>>
>>> keyctl_invalidate immediately removes all references to the key.
>>
>> This change means keyctl_set_timeout fails, since
>> lookup_user_key returns -EKEYREVOKED, for example, when a
>> key is revoked instead of invalidated. The key timeouts
>> are then set to 0 (the default).
>
> Well, I forgot about the original problem I started seeing
> with 3.17 on EL6, due to the commit you cited above:
>
> Oct 30 11:50:52 dali nfsidmap[2547]: key: 0x23eee41 type: gid value: users@oracle.com timeout 600
> Oct 30 11:50:52 dali nfsidmap[2547]: adding new child .id_resolver_child_1: Operation not permitted
> Oct 30 11:50:52 dali nfsidmap[2547]: Failed to add child keyring: Operation not permitted

This is the RHEL-specific fix for keyrings maxing out at 500 entries on
x86_64 -- but now it is broken with an upstream kernel because of the
permissions changes.  I think you're going to want to just use upstream
nfs-utils here.

>>>> When installing a newer kernel causes a fallback to rpc.idmapd,
>>>> is there any risk of an ID mapper behavior change? Loss of
>>>> functionality, for example?
>>>
>>> The functionality should be equivalent - I think they end up in the same
>>> library after making it through the callout/callup interface.
>>>
>>> The newer kernels only do the request-key callout, and rpc.idmapd
>>> won't ever be consulted.
>>
>> Unless nfsidmap is broken by a new kernel API. :-)
>
> Which is indeed what happens: nfsidmap fails due to the new
> permissions requirement, and the kernel falls back to using
> rpc.idmapd.

Is your newer kernel really falling back?  I think it's not even trying
to do that.

> If rpc.idmapd is disabled, not installed, or not provided,
> and nfsidmap can’t be upgraded to use keyctl_invalidate, then
> NFSv4 ID mapping will break when 3.17 is installed. Maybe
> that’s a regression? Or just a gray area . . .

In RHEL7 this is fixed up by getting everything up to date with
upstream.  We won't be releasing 3.17 with EL6 nfs-utils.

Ben
--168445344-2108265295-1414685762=:20279--
