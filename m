Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:32777 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbcC3Snr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 14:43:47 -0400
Received: by mail-ob0-f175.google.com with SMTP id x3so78626932obt.0
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2016 11:43:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFpb4vht+QyL3vVsRqv6n0TZ6x_PK4oQintch00040wBw@mail.gmail.com>
References: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
	<20160330174040.GA12525@fieldses.org>
	<CAHQdGtRyYiC7Ji6Au444bjc-ibBfdJEn=WLG=zy_XfHzzB557A@mail.gmail.com>
	<CAN-5tyFpb4vht+QyL3vVsRqv6n0TZ6x_PK4oQintch00040wBw@mail.gmail.com>
Date: Wed, 30 Mar 2016 14:43:38 -0400
Message-ID: <CAHQdGtTfzfSCan_h4Cue5NrABG=A4=uaBORBfx6wp9gU+7bQmQ@mail.gmail.com>
Subject: Re: out of order v3 write replies and cache invalidation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 30, 2016 at 2:39 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Wed, Mar 30, 2016 at 2:20 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Wed, Mar 30, 2016 at 1:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> If we assume no other writers until we close, couldn't you on close wait
>>> for all writes, send a final getattr for change attribute, and trust
>>> that?  If the extra getattr's too much, then you'd need some algorithm
>>> like the above to determine which change attribute is the last.  Or
>>> implement
>>> https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-12.2.3
>>> on client and server and just track the maximum returned value when the
>>> server returns something other than NFS4_CHANGE_TYPE_IS_UNDEFINED.
>>>
>>
>> The correct tool to use for resolving these caching issues is
>> ultimately a write delegation.
>>
>> You can also eliminate a lot of invalidations if you know that the
>> server implements change_attr_type ==
>> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER or
>> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS, since that allows you to
>> predict what the attribute should be after a change.
>
> Thanks for all the info. But let me highlight that I was asking about
> v3. I don't see that the code has issues with cache invalidation for
> nfsv4 when receiving out-of-order RPCs.
>
> I am not sure if it's worth implementing something that Bruce
> suggests. I just wanted to make sure that what i'm seeing is
> "expected" behavior (caz it's v3) and not a bug.

Yes. The design does expect the occasional false positive cache
invalidation due to RPC request reordering.

Cheers
 Trond
